package;

import boot.Boot;
import plugins.TouchPointerPlugin;
import openfl.display.StageDisplayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import gameplay.PlayState;
#if desktop
import sys.FileSystem;
import plugins.ScreenshotPlugin;
#end
import lime.system.System;
import openfl.Lib;

class InitState extends FlxState
{
    override public function create():Void
    {
        super.create();

        trace("[InitState] Bootstrap avviato");

        FlxG.fixedTimestep = false;

        #if desktop
        verificaFileCritici();
        #end

        configuraFlixel();
        inizializzaServizi();

        avviaPreload();
    }

    // --------------------------------------------------
    // CONFIGURAZIONE FLIXEL (UNA VOLTA SOLA)
    // --------------------------------------------------
    function configuraFlixel():Void
    {
        // Grafica
        FlxSprite.defaultAntialiasing = true;

        // Audio: niente shortcut inutili
        FlxG.sound.volumeUpKeys = null;
        FlxG.sound.volumeDownKeys = null;
        FlxG.sound.muteKeys = null;

        // Performance
        FlxG.game.focusLostFramerate = 20;
        // Mouse
        FlxG.mouse.enabled = true;
        FlxG.mouse.visible = true;

        #if desktop
        ScreenshotPlugin.initialize();
        #end

        #if android
        TouchPointerPlugin.initialize();
        #end

        #if android
        FlxG.android.preventDefaultKeys = [
            flixel.input.android.FlxAndroidKey.BACK
        ];
        #end
    }

    // --------------------------------------------------
    // SERVIZI ESTERNI
    // --------------------------------------------------
    function inizializzaServizi():Void
    {

    }

    // --------------------------------------------------
    // PRELOAD NINTENDO-STYLE (ASINCRONO)
    // --------------------------------------------------
    function avviaPreload():Void
    {
        trace("[InitState] Avvio preload avanzato");
        avviaGioco();
    }

    // --------------------------------------------------
    // AVVIO STATO SUCCESSIVO
    // --------------------------------------------------
    function avviaGioco():Void
    {
        trace("[InitState] Passaggio allo stato successivo");

        FlxG.switchState(Boot.new);
    }

    // --------------------------------------------------
    // VERIFICHE CRITICHE (DESKTOP)
    // --------------------------------------------------
    #if desktop
    function verificaFileCritici():Void
    {
        /*
        if (!FileSystem.exists("assets/Emily.txt"))
        {
            // Crash intenzionale
            throw "Ti ho cercato, ma sono rimasto ferito";
        }
        */
    }
    #end
}