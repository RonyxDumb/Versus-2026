package boot;

import openfl.display.Shape;
import ui.ColorsAesthetic;
import lime.app.Application;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup;
import transition.FNFState;
import input.Controls;

class Boot extends FNFState
{
    inline static var FONT_PATH:String = "assets/fonts/NeutralSans-Regular.otf";

    var logo:FlxSprite;
    var bg:FlxSprite;
    var accentBar:FlxSprite;
    
    // Elementi Menu MD3
    var btnPlay:FlxText;
    var btnCredits:FlxText;
    var selectorPill:FlxSprite; // La tipica "pillola" di selezione Material 3
    
    var currentSelection:Int = 0; // 0 = Gioca, 1 = Crediti
    var exiting:Bool = false;

    // Sfondo dinamico
    var backgroundShapes:FlxTypedGroup<FlxSprite>;
    var versionText:FlxText;

    override public function create()
    {
        super.create();
        FlxG.mouse.visible = true;

        // 1. SFONDO BASE SCURO (Material Dark Surface)
        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, ColorsAesthetic.BLACK);
        add(bg);

        // 2. SISTEMA DI PARTICELLE DECORATIVE DI SFONDO (Generazione elementi fluttuanti)
        backgroundShapes = new FlxTypedGroup<FlxSprite>();
        add(backgroundShapes);
        
        for (i in 0...6) {
            var shapeSize = FlxG.random.int(100, 250);
            var shape = new FlxSprite();
            shape.makeGraphic(shapeSize, shapeSize, ColorsAesthetic.SAGE_PALE);
            shape.x = FlxG.random.float(0, FlxG.width);
            shape.y = FlxG.random.float(0, FlxG.height);
            shape.alpha = FlxG.random.float(0.02, 0.05); // Molto soffuse sullo sfondo
            backgroundShapes.add(shape);

            // Animazione continua e sfalsata per ogni forma
            var duration = FlxG.random.float(6, 12);
            FlxTween.tween(shape, {
                x: shape.x + FlxG.random.float(-100, 100), 
                y: shape.y + FlxG.random.float(-100, 100),
                angle: FlxG.random.float(90, 360)
            }, duration, {type: PINGPONG, ease: FlxEase.quadInOut});
        }

        // 3. BARRA DI ACCENTO IN BASSO CON CAMBIO COLORE GRADUALE
        accentBar = new FlxSprite(0, FlxG.height - 12).makeGraphic(FlxG.width, 12, ColorsAesthetic.GREEN_ACCENT);
        add(accentBar);
        
        // Ciclo continuo di colore sulla barra (Interpolazione Material)
        FlxTween.color(accentBar, 4.0, ColorsAesthetic.GREEN_ACCENT, ColorsAesthetic.OLIVE, {type: PINGPONG, ease: FlxEase.sineInOut});

        // 4. LOGO IN ALTO A SINISTRA (Dimensione imposta via codice, non legata allo sprite)
        logo = new FlxSprite();
        logo.loadGraphic("assets/Textures/Boot/LOGO_PROTO1_stretch.png");
        logo.antialiasing = true;

		// 1. Estraiamo i componenti del tuo colore (es. GREEN_ACCENT)
		var targetColor:FlxColor = ColorsAesthetic.LIGHTER;
		var r:Float = targetColor.red / 255;
		var g:Float = targetColor.green / 255;
		var b:Float = targetColor.blue / 255;

		// 2. Creiamo una matrice che ignora il colore di base e spinge il target sui canali RGB
		// mantenendo l'alpha (la trasparenza) originale del file
		var matrix:Array<Float> = [
			0, 0, 0, 0, targetColor.red,
			0, 0, 0, 0, targetColor.green,
			0, 0, 0, 0, targetColor.blue,
			0, 0, 0, 1, 0
		];

		var filter = new openfl.filters.ColorMatrixFilter(matrix);

		// 3. Applichiamo il filtro hardware sulla bitmap del logo
		logo.pixels.applyFilter(logo.pixels, logo.pixels.rect, new openfl.geom.Point(0, 0), filter);
        
        // Forza dimensioni assolute indipendentemente dal file sorgente
        var targetLogoWidth:Float = 600; 
        var targetLogoHeight:Float = 250;
        logo.scale.set(targetLogoWidth / logo.frameWidth, targetLogoHeight / logo.frameHeight);
        logo.updateHitbox();
        
        // Posizionamento asimmetrico in alto a sinistra
        logo.x = 50;
        logo.y = 50;
        add(logo);

        // 5. SELETTORE A PILLOLA DI BACKGROUND (MD3 Navigation Design)
        // Viene posizionato dietro al testo selezionato per evidenziarlo
        selectorPill = new FlxSprite().makeGraphic(240, 75, ColorsAesthetic.MID_DARK);
        selectorPill.alpha = 0.6;
		selectorPill.pixels = getRoundedBitmap(selectorPill, 40);
        // Rendiamo i bordi della pillola smussati se usi la funzione rounded precedentemente creata!
        add(selectorPill);

        // 6. TESTI DI SELEZIONE AFFIANCATI (Grandi ed Ergonomici)
        var menuY = FlxG.height * 0.55; // Posizionamento centrale comodo per il pollice
        
        btnPlay = new FlxText(FlxG.width * 0.22, menuY, 300, "GIOCA");
        btnPlay.setFormat(FONT_PATH, 38, ColorsAesthetic.TEXT_PRIMARY, CENTER);
        add(btnPlay);

        btnCredits = new FlxText(FlxG.width * 0.53, menuY, 300, "CREDITI");
        btnCredits.setFormat(FONT_PATH, 38, ColorsAesthetic.TEXT_MUTED, CENTER);
        add(btnCredits);

        // Versione applicazione (MD3 Muted bottom corner)
        versionText = new FlxText(50, FlxG.height - 50, 400, "v" + Application.current.meta.get("version"));
        versionText.setFormat(FONT_PATH, 46, ColorsAesthetic.TEXT_MUTED, LEFT);
        add(versionText);

        // 7. ANIMAZIONE D'INGRESSO E LOOP DEL LOGO
        logo.alpha = 0;
        FlxTween.tween(logo, {alpha: 1}, 0.6, {ease: FlxEase.quadOut});
        // Respiro continuo del logo (Idling)
        FlxTween.tween(logo.scale, {x: logo.scale.x * 1.06, y: logo.scale.y * 1.06}, 1.4, {type: PINGPONG, ease: FlxEase.sineInOut});

        updateSelectionVisuals(false);
    }

	function getRoundedBitmap(sprite:FlxSprite, cornerSize:Int = 32):openfl.display.BitmapData
	{
		var originalBmd = sprite.pixels;
		var roundedBmd = new openfl.display.BitmapData(originalBmd.width, originalBmd.height, true, 0);
		
		var shape = new Shape();
		shape.graphics.beginBitmapFill(originalBmd);
		shape.graphics.drawRoundRect(0, 0, originalBmd.width, originalBmd.height, cornerSize, cornerSize);
		shape.graphics.endFill();
		
		roundedBmd.draw(shape);
		
		return roundedBmd;
	}

    override public function update(elapsed:Float)
	{
		super.update(elapsed);
		Controls.update();

		if (exiting) return;

		// 1. GESTIONE NAVIGAZIONE (Accetta sia WASD del Player 1 che le freccette universali)
		var moveLeft:Bool = Controls.player1.leftPressed || FlxG.keys.justPressed.LEFT;
		var moveRight:Bool = Controls.player1.rightPressed || FlxG.keys.justPressed.RIGHT;

		if (moveLeft) changeSelection(-1);
		if (moveRight) changeSelection(1);

		// 2. GESTIONE CONFERMA (Accetta l'invio del Player 1, la Barra Spaziatrice o il tasto ENTER della tastiera)
		var confirmAction:Bool = Controls.player1.confirmPressed || FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE;
		
		if (confirmAction) selectCurrentOption();

		// 3. SUPPORTO TOTALMENTE TOUCH PER ANDROID
		#if android
		for (touch in FlxG.touches.list) {
			if (touch.justPressed) {
				if (touch.screenY > btnPlay.y - 30 && touch.screenY < btnPlay.y + 100) {
					if (touch.screenX > btnPlay.x && touch.screenX < btnPlay.x + btnPlay.width) {
						if (currentSelection == 0) selectCurrentOption();
						else { currentSelection = 0; updateSelectionVisuals(true); }
					}
					else if (touch.screenX > btnCredits.x && touch.screenX < btnCredits.x + btnCredits.width) {
						if (currentSelection == 1) selectCurrentOption();
						else { currentSelection = 1; updateSelectionVisuals(true); }
					}
				}
			}
		}
		#else
		// Supporto Mouse per PC
		if (FlxG.mouse.justPressed) {
			if (FlxG.mouse.screenY > btnPlay.y - 30 && FlxG.mouse.screenY < btnPlay.y + 100) {
				if (FlxG.mouse.screenX > btnPlay.x && FlxG.mouse.screenX < btnPlay.x + btnPlay.width) {
					if (currentSelection == 0) selectCurrentOption();
					else { currentSelection = 0; updateSelectionVisuals(true); }
				}
				else if (FlxG.mouse.screenX > btnCredits.x && FlxG.mouse.screenX < btnCredits.x + btnCredits.width) {
					if (currentSelection == 1) selectCurrentOption();
					else { currentSelection = 1; updateSelectionVisuals(true); }
				}
			}
		}
		#end
	}

    function changeSelection(dir:Int)
    {
        currentSelection += dir;
        if (currentSelection < 0) currentSelection = 1;
        if (currentSelection > 1) currentSelection = 0;
        
        updateSelectionVisuals(true);
    }

    function updateSelectionVisuals(animated:Bool)
    {
        var targetText = (currentSelection == 0) ? btnPlay : btnCredits;
        var nonTargetText = (currentSelection == 0) ? btnCredits : btnPlay;

        targetText.color = ColorsAesthetic.GREEN_ACCENT;
        nonTargetText.color = ColorsAesthetic.TEXT_MUTED;

        // Calcolo centro esatto del testo attivo per muovere la pillola Material 3
        var targetX = targetText.x + (targetText.width / 2) - (selectorPill.width / 2);
        var targetY = targetText.y + (targetText.height / 2) - (selectorPill.height / 2) + 5;

        FlxTween.cancelTweensOf(selectorPill);
        FlxTween.cancelTweensOf(btnPlay.scale);
        FlxTween.cancelTweensOf(btnCredits.scale);

        if (animated) {
            // Movimento fluido ad elastico della pillola di selezione
            FlxTween.tween(selectorPill, {x: targetX, y: targetY}, 0.25, {ease: FlxEase.backOut});
            
            // Effetto "pop" di ingrandimento sul testo selezionato
            FlxTween.tween(targetText.scale, {x: 1.1, y: 1.1}, 0.2, {ease: FlxEase.quadOut});
            FlxTween.tween(nonTargetText.scale, {x: 1.0, y: 1.0}, 0.2, {ease: FlxEase.quadOut});
        } else {
            selectorPill.x = targetX;
            selectorPill.y = targetY;
            targetText.scale.set(1.1, 1.1);
            nonTargetText.scale.set(1.0, 1.0);
        }
    }

    function selectCurrentOption()
    {
        exiting = true;
        FlxG.camera.flash(ColorsAesthetic.GREEN_ACCENT, 0.35);

        // Animazione esplosiva in uscita di tutta la UI
        FlxTween.tween(logo, {alpha: 0, y: logo.y - 40}, 0.4, {ease: FlxEase.backIn});
        FlxTween.tween(btnPlay, {alpha: 0, y: btnPlay.y + 40}, 0.4, {ease: FlxEase.backIn});
        FlxTween.tween(btnCredits, {alpha: 0, y: btnCredits.y + 40}, 0.4, {ease: FlxEase.backIn});
        FlxTween.tween(selectorPill, {alpha: 0}, 0.3);

        new FlxTimer().start(0.45, function(_) {
            if (currentSelection == 0) {
                FlxG.switchState(new CharacterSelectState2());
            } else {
                // Qui andrà il tuo stato dei Crediti (es. CreditsState)
                // Per ora rimette a posto se non esiste
                exiting = false;
                FlxG.resetState();
            }
        });
    }
}