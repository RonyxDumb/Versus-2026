package gameplay;

import audio.MusTable;
import audio.SoundTable;
import boot.Boot;
import camera.CameraFX;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import input.Controls;
import player.CharacterDatabase;
import player.CharacterSelection;
import player.Player1;
import player.Player2;
import transition.FNFState;

// Importiamo il Virtual Pad e l'interfaccia UI nativa di Flixel solo per Android
#if android
import flixel.ui.FlxButton;
import flixel.ui.FlxVirtualPad;
#end

class PlayState extends FNFState
{
    var player1:Player1;
    var player2:Player2;
    var exiting:Bool = false;
    var gameStarted:Bool = false;

    // Memorizziamo le scale originali definite nelle classi Player per non alterarle//
    var p1TargetScaleX:Float = 1.0;
    var p1TargetScaleY:Float = 1.0;
    var p2TargetScaleX:Float = 1.0;
    var p2TargetScaleY:Float = 1.0;

    // Flag di sicurezza per evitare collisioni multiple durante il freeze frame dell'hitstop//
    var canCollide:Bool = true;

    // Variabile per tenere traccia di quale BGM casuale è stata scelta//
    var currentBGM:FlxSound;

    // --- CONTROLLI TOUCH E CAMERAS ANDROID ---
    #if android
    var virtualPadP1:FlxVirtualPad;
    var pauseButton:FlxButton;
    var hudCamera:FlxCamera;
    #end

    override public function create()
    {
        super.create();

        // Configurazione telecamera standard (Ripristinata senza animazioni di ingresso)//
        FlxG.camera.zoom = 1.0; 
        FlxG.camera.scroll.set(0, 0); 

        // Inizializzazione corretta dei registri audio//
        MusTable.init();
        SoundTable.init();
        SoundTable.START_GAME.play();

        var bg = FlxGridOverlay.create(
            32, // larghezza cella
            32, // altezza cella
            5000, // larghezza totale
            5000 // altezza totale
        );
        add(bg);

        // Setup Player 1//
        player1 = new Player1(100, 100);
        player1.visible = false;
        player1.active = false;
        
        // Salviamo la scala nativa impostata dal costruttore per evitare che diventino enormi//
        p1TargetScaleX = player1.scale.x;
        p1TargetScaleY = player1.scale.y;
        player1.scale.set(0, 0); // Azzerato momentaneamente solo per l'effetto di spawn//
        add(player1);

        // Setup Player 2//
        player2 = new Player2(600, 500);
        player2.visible = false;
        player2.active = false;
        
        // Salviamo la scala nativa impostata dal costruttore per evitare che diventino enormi//
        p2TargetScaleX = player2.scale.x;
        p2TargetScaleY = player2.scale.y;
        player2.scale.set(0, 0); // Azzerato momentaneamente solo per l'effetto di spawn//
        add(player2);

        // --- INIZIALIZZAZIONE HUD VIRTUAL PAD E TELECAMERA DEDICATA (SOLO ANDROID) ---
        #if android
        // Creiamo una telecamera separata per l'interfaccia grafica per evitare che subisca lo zoom della mappa
        hudCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        hudCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(hudCamera, false);

        // Player 1: D-Pad Completo a sinistra, pulsante A (Salto) e B (Attacco/Azione) a destra//
        virtualPadP1 = new FlxVirtualPad(FULL, A_B);
        virtualPadP1.scale.set(1.5, 1.5); // Scala il pad del 50% in più
        virtualPadP1.updateHitbox();       // Aggiorna l'area di tocco per corrispondere alla nuova scala
        virtualPadP1.alpha = 0.5; // Trasparente per non coprire troppo lo schermo//
        
        // Assegniamo gli sprite del pad esclusivamente alla telecamera HUD e rimuoviamo i fattori di scorrimento
        virtualPadP1.forEach(function(sprite:FlxSprite) {
            sprite.scrollFactor.set(0, 0);
            sprite.cameras = [hudCamera];
        });
        add(virtualPadP1);

        // Sistema di ritorno / Pausa per tornare indietro tramite interfaccia grafica
        pauseButton = new FlxButton(FlxG.width - 100, 20, "INDIETRO", function() {
            exiting = true;
        });
        pauseButton.cameras = [hudCamera];
        pauseButton.scrollFactor.set(0, 0);
        add(pauseButton);
        #end
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        Controls.update();

        if (!gameStarted)
        {
            if (!SoundTable.START_GAME.playing)
            {
                gameStarted = true;

                // Attivazione fisica dei Player//
                player1.visible = true;
                player1.active = true;
                player2.visible = true;
                player2.active = true;

                // Animazione di Spawn scalata sui valori corretti e originari dei personaggi//
                FlxTween.tween(player1.scale, {x: p1TargetScaleX, y: p1TargetScaleY}, 0.4, {ease: FlxEase.backOut});
                FlxTween.tween(player2.scale, {x: p2TargetScaleX, y: p2TargetScaleY}, 0.4, {ease: FlxEase.backOut});

                // Flash bianco leggero all'inizio del match//
                FlxG.camera.flash(FlxColor.WHITE, 0.2);

                // --- SELEZIONE CASUALE DELLA TRACCIA AGGIORNATA ---
                var randomChoice:Int = FlxG.random.int(0, 4);
                switch (randomChoice)
                {
                    case 0:
                        currentBGM = MusTable.BGM_COOP;
                        trace("Traccia scelta: BGM_COOP");
                    case 1:
                        currentBGM = MusTable.BGM_COOP_BONUS;
                        trace("Traccia scelta: BGM_COOP_BONUS");
                    case 2:
                        currentBGM = MusTable.BGM_COOP_SKY;
                        trace("Traccia scelta: BGM_COOP_SKY");
                    case 3:
                        currentBGM = MusTable.BGM_COOP_8BIT;
                        trace("Traccia scelta: BGM_COOP_8BIT");
                    case 4:
                        currentBGM = MusTable.BGM_COOP_RES;
                        trace("Traccia scelta: BGM_COOP_RES");
                    default:
                        currentBGM = MusTable.BGM_COOP;
                }

                if (currentBGM != null)
                {
                    currentBGM.play();
                }
                else
                {
                    var erroreTraccia:String = "";
                    if (randomChoice == 0) erroreTraccia = "BGM_COOP";
                    if (randomChoice == 1) erroreTraccia = "BGM_COOP_BONUS";
                    if (randomChoice == 2) erroreTraccia = "BGM_COOP_SKY";
                    if (randomChoice == 3) erroreTraccia = "BGM_COOP_8BIT";
                    if (randomChoice == 4) erroreTraccia = "BGM_COOP_RES";
                    
                    trace("ERRORE CRITICO: La variabile MusTable." + erroreTraccia + " è NULL! Controlla MusTable.hx.");
                }
            }

            // Blocca l'esecuzione delle logiche finché il gioco non è partito//
            return;
        }
        // Muove la camera solo se i player sono istanziati e attivi//
        updateCamera(elapsed);

        // --- LOGICA DI SCONTRO E RESPINGIMENTO TRA GIOCATORI ---
        if (canCollide && FlxG.overlap(player1, player2))
        {
            handlePlayerCollision();
        }

        var leavePressed:Bool = FlxG.keys.justPressed.ESCAPE;

        for (pad in FlxG.gamepads.getActiveGamepads())
        {
            if (pad.justPressed.BACK || pad.justPressed.B)
            {
                leavePressed = true;
                break;
            }
        }

        // ANTISPAM USCITA: Se tocchi il tasto back virtuale o fisico su Android, o premi il tasto della UI
        #if android
        if (FlxG.android.justPressed.BACK) {
            leavePressed = true;
        }
        if (exiting) { // Se è stato triggerato dal pulsante HUD a schermo
            leavePressed = true;
        }
        #end

        if (!exiting && leavePressed)
        {
            exiting = true;

            // Ripristina il timeScale se usciamo durante un impatto//
            FlxG.timeScale = 1.0;

            SoundTable.START_GAME.stop();
            
            if (currentBGM != null)
                currentBGM.stop();

            FlxG.switchState(new Boot());
        }
    }

    function handlePlayerCollision():Void
    {
        canCollide = false; // Blocca immediatamente ulteriori calcoli di scontro (Antispam collisioni)//

        var p1:FlxPoint = player1.getMidpoint();
        var p2:FlxPoint = player2.getMidpoint();

        var diffX:Float = p1.x - p2.x;
        var diffY:Float = p1.y - p2.y;

        // --- HITSTOP EFFECT (Nintendo Freeze Frame Sicuro via Haxe Timer) ---
        FlxG.timeScale = 0.001; 

        haxe.Timer.delay(function() {
            FlxG.timeScale = 1.0; // Ripristina la velocità normale del motore//
            canCollide = true;    // Riabilita il controllo delle collisioni//
        }, 80); 

        if (Math.abs(diffY) > 24)
        {
            // --- CASO A: SCONTRO DALL'ALTO (Salta sopra) ---
            if (p1.y < p2.y)
            {
                player1.velocity.y = -600; 
                player1.y -= 32; // Spostamento netto per separare immediatamente le hitbox//          
                player2.velocity.x = (p2.x > p1.x ? 1 : -1) * 300;
                trace("Player 1 è saltato sopra Player 2!");
            }
            else
            {
                player2.velocity.y = -600; 
                player2.y -= 32;           
                player1.velocity.x = (p1.x > p2.x ? 1 : -1) * 300;
                trace("Player 2 è saltato sopra Player 1!");
            }

            CameraFX.play(VERSUS_GROUND_POUND, 1.2);
            FlxG.camera.flash(0xCCFFCC00, 0.1);
        }
        else
        {
            // --- CASO B: SCONTRO ORIZZONTALE (Faccia a Faccia) ---
            if (diffX == 0) diffX = FlxG.random.sign();

            var dirX:Float = diffX > 0 ? 1 : -1;
            var SUPER_PUSH:Float = 1200;

            player1.velocity.x = dirX * SUPER_PUSH;
            player2.velocity.x = -dirX * SUPER_PUSH;

            // Spostamento immediato in pixel per staccarli istantaneamente prima del frame successivo//
            player1.x += dirX * 45;
            player2.x -= dirX * 45;

            trace("Scontro faccia a faccia! I giocatori si respingono.");
            
            CameraFX.play(VERSUS_HIT_BY_SHELL, 1.8); 
            FlxG.camera.flash(0xFFFF3333, 0.1);
        }

        p1.put();
        p2.put();
    }

    function updateCamera(elapsed:Float):Void
    {
        var p1:FlxPoint = player1.getMidpoint();
        var p2:FlxPoint = player2.getMidpoint();

        var centerX:Float = (p1.x + p2.x) * 0.5;
        var centerY:Float = (p1.y + p2.y) * 0.5;

        var targetScrollX:Float = centerX - (FlxG.width * 0.5);
        var targetScrollY:Float = centerY - (FlxG.height * 0.5);

        FlxG.camera.scroll.x += (targetScrollX - FlxG.camera.scroll.x) * 4.5 * elapsed;
        FlxG.camera.scroll.y += (targetScrollY - FlxG.camera.scroll.y) * 4.5 * elapsed;

        var dx:Float = p1.x - p2.x;
        var dy:Float = p1.y - p2.y;
        var distance:Float = Math.sqrt(dx * dx + dy * dy);

        // --- UNZOOM INFINITO ---
        var targetZoom:Float = 450 / Math.max(distance, 350);

        if (targetZoom > 1.0) targetZoom = 1.0;

        FlxG.camera.zoom += (targetZoom - FlxG.camera.zoom) * 4 * elapsed;
            
        p1.put();
        p2.put();
    }

    override public function destroy()
    {
        #if android
        if (virtualPadP1 != null) virtualPadP1 = flixel.util.FlxDestroyUtil.destroy(virtualPadP1);
        if (pauseButton != null) pauseButton = flixel.util.FlxDestroyUtil.destroy(pauseButton);
        #end
        super.destroy();
    }
}