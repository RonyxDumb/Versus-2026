package boot;

import openfl.display.BitmapData;
import openfl.display.Shape;
import ui.ColorsAesthetic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import input.Controls;
import player.CharacterDatabase;
import player.CharacterSelection;
import gameplay.PlayState;
import transition.FNFState;

class CharacterSelectState2 extends FNFState
{
    inline static var FONT_PATH:String = "assets/fonts/audex.regular.otf";

    var p1Index:Int = 0;
    var p2Index:Int = 0;
    var p1Ready:Bool = false;
    var p2Ready:Bool = false;
    
    var awaitingGlobalConfirm:Bool = false;
    var leaving:Bool = false;

    // Componenti P1
    var p1Texts:Array<FlxText> = [];
    var p1Arrow:FlxText;
    var p1Preview:FlxSprite;
    var p1StatusText:FlxText;

    // Componenti P2
    var p2Texts:Array<FlxText> = [];
    var p2Arrow:FlxText;
    var p2Preview:FlxSprite;
    var p2StatusText:FlxText;

    var darkOverlay:FlxSprite;
    var globalPromptText:FlxText;

    var col1CenterX:Float;
    var col2CenterX:Float;
    var colWidth:Int;
    var centerListY:Float;
    
    var spacingY:Float = 80; 

    var btnP1Up:FlxSprite;
    var btnP1Down:FlxSprite;
    var btnP2Up:FlxSprite;
    var btnP2Down:FlxSprite;

    var dividerLine:FlxSprite;

    override public function create()
    {
        super.create();

        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, ColorsAesthetic.BLACK);
        add(bg);

        colWidth = Std.int(FlxG.width * 0.45);
        col1CenterX = FlxG.width * 0.05 + (colWidth / 2);
        col2CenterX = FlxG.width * 0.50 + (colWidth / 2);
        
        // CORRETTO: Spostato ancora più in basso per lasciare tutto lo spazio alla preview
        centerListY = FlxG.height * 0.82;

        var p1Title = new FlxText(FlxG.width * 0.05, 30, colWidth, "Giocatore 1");
        p1Title.setFormat(FONT_PATH, 40, ColorsAesthetic.SAGE_PALE, CENTER);
        add(p1Title);

        var p2Title = new FlxText(FlxG.width * 0.50, 30, colWidth, "Giocatore 2");
        p2Title.setFormat(FONT_PATH, 40, ColorsAesthetic.SAGE_PALE, CENTER);
        add(p2Title);

        // CORRETTO: Rimosso il "var" davanti, ora assegnano correttamente alle variabili di classe!
        p1StatusText = new FlxText(FlxG.width * 0.05, 70, colWidth, "Scegli...");
        p1StatusText.setFormat(FONT_PATH, 20, ColorsAesthetic.TEXT_MUTED, CENTER);
        add(p1StatusText);

        p2StatusText = new FlxText(FlxG.width * 0.50, 70, colWidth, "In attesa...");
        p2StatusText.setFormat(FONT_PATH, 20, ColorsAesthetic.TEXT_MUTED, CENTER);
        add(p2StatusText);

        p1Preview = new FlxSprite();
        add(p1Preview);

        p2Preview = new FlxSprite();
        add(p2Preview);

        p1Arrow = new FlxText(FlxG.width * 0.05, centerListY - 45, colWidth, "▾");
        p1Arrow.setFormat(FONT_PATH, 32, ColorsAesthetic.GREEN_ACCENT, CENTER);
        add(p1Arrow);

        p2Arrow = new FlxText(FlxG.width * 0.50, centerListY - 45, colWidth, "▾");
        p2Arrow.setFormat(FONT_PATH, 32, ColorsAesthetic.GREEN_ACCENT, CENTER);
        p2Arrow.visible = false;
        add(p2Arrow);

        // Linea di divisione centrale sottile ed elegante
        var lineWidth:Int = 2;
        var lineHeight:Int = Std.int(FlxG.height * 0.85); // Non tocca i bordi estremi dello schermo

        dividerLine = new FlxSprite(0, 0).makeGraphic(lineWidth, lineHeight, ColorsAesthetic.TEXT_MUTED);
        dividerLine.screenCenter(Y); // Centra verticalmente
        dividerLine.x = (FlxG.width / 2) - (lineWidth / 2); // Centra orizzontalmente spaccato al millimetro
        dividerLine.alpha = 0.15; // Molto discreta per non appesantire l'interfaccia
        add(dividerLine);

        var chars = CharacterDatabase.CHARACTERS;
        for (i in 0...chars.length) {
            var nameLower = chars[i].name.toLowerCase();

            var t1 = new FlxText(FlxG.width * 0.05, centerListY, colWidth, nameLower);
            t1.setFormat(FONT_PATH, 22, ColorsAesthetic.TEXT_PRIMARY, CENTER);
            add(t1);
            p1Texts.push(t1);

            var t2 = new FlxText(FlxG.width * 0.50, centerListY, colWidth, nameLower);
            t2.setFormat(FONT_PATH, 22, ColorsAesthetic.TEXT_PRIMARY, CENTER);
            add(t2);
            p2Texts.push(t2);
        }

        var materialScuro = FlxColor.BLACK;
        darkOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, materialScuro);
        darkOverlay.alpha = 0;
        add(darkOverlay);

        globalPromptText = new FlxText(0, FlxG.height * 0.45, FlxG.width, "Premi conferma per giocare\n[cancella] per tornare indietro");
        globalPromptText.setFormat(FONT_PATH, 50, ColorsAesthetic.GREEN_ACCENT, CENTER);
        globalPromptText.visible = false;
        add(globalPromptText);

        updateListScrolling(1, false);
        updateListScrolling(2, false);

        setupAndroidControls();
    }

    function getRoundedBitmap(sprite:FlxSprite, cornerSize:Int = 32):openfl.display.BitmapData
    {
        // Recuperiamo la bitmap originale dello sprite
        var originalBmd = sprite.pixels;
        
        // Creiamo una nuova bitmap vuota e trasparente delle stesse dimensioni
        var roundedBmd = new BitmapData(originalBmd.width, originalBmd.height, true, 0);
        
        // Usiamo la grafica nativa di OpenFL per disegnare il rettangolo smussato
        var shape = new Shape();
        shape.graphics.beginBitmapFill(originalBmd);
        shape.graphics.drawRoundRect(0, 0, originalBmd.width, originalBmd.height, cornerSize, cornerSize);
        shape.graphics.endFill();
        
        // Stampiamo la forma geometrica sulla nuova bitmap trasparente
        roundedBmd.draw(shape);
        
        return roundedBmd;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        if (leaving) return;

        if (awaitingGlobalConfirm) {
            if (Controls.player1.confirmPressed || Controls.player2.confirmPressed) {
                startMatch();
                return;
            }
            if (Controls.player1.cancelPressed || Controls.player2.cancelPressed) {
                awaitingGlobalConfirm = false;
                globalPromptText.visible = false;
                FlxTween.cancelTweensOf(darkOverlay);
                FlxTween.tween(darkOverlay, {alpha: 0.0}, 0.2, {ease: FlxEase.quadOut});
                setPlayerReady(2, false);
                return;
            }
            return; 
        }

        if (!p1Ready) {
            if (Controls.player1.upPressed) changeSelection(1, -1);
            if (Controls.player1.downPressed) changeSelection(1, 1);
            if (Controls.player1.confirmPressed) {
                setPlayerReady(1, true);
                p2StatusText.text = "Scegli...";
                p2StatusText.color = ColorsAesthetic.TEXT_PRIMARY;
                p2Arrow.visible = true;
            }
        } 
        else if (p1Ready && !p2Ready) {
            if (Controls.player1.cancelPressed) {
                setPlayerReady(1, false);
                p2StatusText.text = "In attesa...";
                p2StatusText.color = ColorsAesthetic.TEXT_MUTED;
                p2Arrow.visible = false;
                return;
            }

            if (Controls.player2.upPressed) changeSelection(2, -1);
            if (Controls.player2.downPressed) changeSelection(2, 1);
            if (Controls.player2.confirmPressed) {
                setPlayerReady(2, true);
                awaitingGlobalConfirm = true;
                globalPromptText.visible = true;
                FlxTween.cancelTweensOf(darkOverlay);
                FlxTween.tween(darkOverlay, {alpha: 0.95}, 0.25, {ease: FlxEase.quadOut});
            }
            if (Controls.player2.cancelPressed) {
                setPlayerReady(1, false);
                p2StatusText.text = "In attesa...";
                p2StatusText.color = ColorsAesthetic.TEXT_MUTED;
                p2Arrow.visible = false;
            }
        }

        #if android
        for (touch in FlxG.touches.list) {
            if (touch.justPressed) {
                if (awaitingGlobalConfirm) {
                    if (touch.screenY > FlxG.height * 0.4 && touch.screenY < FlxG.height * 0.6) startMatch();
                    else { 
                        awaitingGlobalConfirm = false; 
                        globalPromptText.visible = false; 
                        FlxTween.cancelTweensOf(darkOverlay);
                        FlxTween.tween(darkOverlay, {alpha: 0.0}, 0.2, {ease: FlxEase.quadOut});
                        setPlayerReady(2, false); 
                    }
                    return;
                }

                if (touch.overlaps(btnP1Up) && !p1Ready) changeSelection(1, -1);
                else if (touch.overlaps(btnP1Down) && !p1Ready) changeSelection(1, 1);
                else if (touch.overlaps(btnP2Up) && p1Ready && !p2Ready) changeSelection(2, -1);
                else if (touch.overlaps(btnP2Down) && p1Ready && !p2Ready) changeSelection(2, 1);
            }
        }
        #end
    }

    function changeSelection(player:Int, dir:Int)
    {
        var total = CharacterDatabase.CHARACTERS.length;
        if (player == 1) {
            p1Index = (p1Index + dir + total) % total;
            updateListScrolling(1, true);
        } else {
            p2Index = (p2Index + dir + total) % total;
            updateListScrolling(2, true);
        }
    }

    function updateListScrolling(player:Int, animated:Bool)
    {
        var currentIndex = (player == 1) ? p1Index : p2Index;
        var texts = (player == 1) ? p1Texts : p2Texts;
        var preview = (player == 1) ? p1Preview : p2Preview;
        var centerX = (player == 1) ? col1CenterX : col2CenterX;

        for (i in 0...texts.length) {
            FlxTween.cancelTweensOf(texts[i]);
            var targetY = centerListY + ((i - currentIndex) * spacingY);
            var diff = Math.abs(i - currentIndex);
            
            // CORRETTO: Mostra SOLO l'elemento selezionato (diff == 0) e quelli immediatamente adiacenti (diff == 1). 
            // Gli altri spariscono totalmente (alpha = 0) in modo da non toccare la preview.
            var targetAlpha:Float = 0.0;
            if (diff == 0) {
                targetAlpha = 1.0;
                texts[i].size = 34;
            } else if (diff == 1) {
                targetAlpha = 0.3; // Molto soft per non disturbare lo schermo
                texts[i].size = 22;
            } else {
                texts[i].size = 22;
            }

            if (animated) {
                FlxTween.tween(texts[i], {y: targetY, alpha: targetAlpha}, 0.22, {ease: FlxEase.cubeOut});
            } else {
                texts[i].y = targetY;
                texts[i].alpha = targetAlpha;
            }

            texts[i].color = (i == currentIndex) ? ColorsAesthetic.TEXT_PRIMARY : ColorsAesthetic.TEXT_MUTED;
        }

        var data = CharacterDatabase.CHARACTERS[currentIndex];
        preview.loadGraphic(Paths.textures(data.texture));

        preview.pixels = getRoundedBitmap(preview, 300);
        
        var maxH = FlxG.height * 0.55; 
        var ratio = maxH / preview.frameHeight;
        preview.scale.set(ratio, ratio);
        preview.updateHitbox();

        preview.x = centerX - (preview.width / 2);
        preview.y = 100;

        if (animated) {
            preview.scale.set(ratio * 0.94, ratio * 0.94);
            FlxTween.tween(preview.scale, {x: ratio, y: ratio}, 0.25, {ease: FlxEase.backOut});
        }
    }

    function setPlayerReady(player:Int, ready:Bool)
    {
        if (player == 1) {
            p1Ready = ready;
            p1StatusText.text = p1Ready ? "Pronto!" : "Scegli...";
            p1StatusText.color = p1Ready ? ColorsAesthetic.GREEN_ACCENT : ColorsAesthetic.TEXT_PRIMARY;
            p1Arrow.visible = !p1Ready;
            p1Preview.color = p1Ready ? ColorsAesthetic.OLIVE : FlxColor.WHITE;
        } else {
            p2Ready = ready;
            p2StatusText.text = p2Ready ? "Pronto!" : "Scegli...";
            p2StatusText.color = p2Ready ? ColorsAesthetic.GREEN_ACCENT : ColorsAesthetic.TEXT_PRIMARY;
            p2Arrow.visible = !p2Ready;
            p2Preview.color = p2Ready ? ColorsAesthetic.OLIVE : FlxColor.WHITE;
        }
    }

    function startMatch()
    {
        leaving = true;
        CharacterSelection.player1 = p1Index;
        CharacterSelection.player2 = p2Index;
        FlxG.camera.flash(ColorsAesthetic.GREEN_ACCENT, 0.35);
        new FlxTimer().start(0.4, _ -> FlxG.switchState(new PlayState()));
    }

    function setupAndroidControls()
    {
        var btnY = FlxG.height - 115;
        var btnW = 140; 
        var btnH = 85;  

        btnP1Up = new FlxSprite(FlxG.width * 0.05, btnY).makeGraphic(btnW, btnH, ColorsAesthetic.MID_DARK);
        btnP1Down = new FlxSprite(FlxG.width * 0.05 + btnW + 20, btnY).makeGraphic(btnW, btnH, ColorsAesthetic.MID_DARK);
        
        btnP2Up = new FlxSprite(FlxG.width * 0.50, btnY).makeGraphic(btnW, btnH, ColorsAesthetic.MID_DARK);
        btnP2Down = new FlxSprite(FlxG.width * 0.50 + btnW + 20, btnY).makeGraphic(btnW, btnH, ColorsAesthetic.MID_DARK);

        #if android
        add(btnP1Up); add(btnP1Down);
        add(btnP2Up); add(btnP2Down);

        var t1U = new FlxText(btnP1Up.x, btnY + 26, btnW, "SU", 22); t1U.setFormat(FONT_PATH, 22, FlxColor.WHITE, CENTER); add(t1U);
        var t1D = new FlxText(btnP1Down.x, btnY + 26, btnW, "GIU", 22); t1D.setFormat(FONT_PATH, 22, FlxColor.WHITE, CENTER); add(t1D);
        var t2U = new FlxText(btnP2Up.x, btnY + 26, btnW, "SU", 22); t2U.setFormat(FONT_PATH, 22, FlxColor.WHITE, CENTER); add(t2U);
        var t2D = new FlxText(btnP2Down.x, btnY + 26, btnW, "GIU", 22); t2D.setFormat(FONT_PATH, 22, FlxColor.WHITE, CENTER); add(t2D);
        #end
    }
}