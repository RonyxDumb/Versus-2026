package;

import plugins.TouchPointerPlugin;
import openfl.display.FPS;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
#if desktop
import sys.FileSystem;
import sys.io.File;
#end
import openfl.filters.ShaderFilter;
import flixel.FlxCamera;
import flixel.addons.display.FlxRuntimeShader;
import flixel.system.scaleModes.RatioScaleMode;
/**
 * Classe principale che inizializza HaxeFlixel e avvia il gioco nel suo state iniziale.
 */
class Main extends Sprite
{
  var gameWidth:Int = 1280;// Larghezza del gioco in pixel (potrebbe essere inferiore/superiore in pixel effettivi a seconda dello zoom).
  var gameHeight:Int = 720; // Altezza del gioco in pixel (potrebbe essere inferiore/superiore in pixel effettivi a seconda dello zoom).
  var initialState:Class<FlxState> = InitState; // FlxState con cui il gioco comincia
  var zoom:Float = -1; // Se -1, lo zoom viene calcolato automaticamente per adattarsi alle dimensioni della finestra.
  #if web
  var framerate:Int = 60; // A quanti fotogrammi per secondo deve correre il gioco (se esportato per web)
  #else
  var framerate:Int = 144; // A quanti fotogrammi per secondo deve correre il gioco (se esportato per qualunque altro target)
  #end
  var skipSplash:Bool = true; // Se saltare la schermata iniziale di flixel che appare nella modalità di rilascio.
  var startFullscreen:Bool = false; // Se avviare il gioco a schermo intero sui target desktop

  public static function main():Void
  {
    Lib.current.addChild(new Main());
  }

  public function new()
  {
    super();

    if (stage != null)
    {
      init();
    }
    else
    {
      addEventListener(Event.ADDED_TO_STAGE, init);
    }
  }

  function init(?event:Event):Void
  {
    if (hasEventListener(Event.ADDED_TO_STAGE))
    {
      removeEventListener(Event.ADDED_TO_STAGE, init);
    }

    setupGame();
  }

  /**
   * Un contatore di fotogrammi mostrato in alto a sinistra.
   */
  public static var fpsCounter:FPS;

  /**
   * Un contatore di RAM mostrato in alto a sinistra.
   */
// public static var memoryCounter:MemoryCounter;

  function setupGame():Void
  {
    #if debug
    fpsCounter = new FPS(10, 3, 0xFFFFFF);
    #end

    // Se siamo su Android, impostiamo 0, 0 per usare l'intero schermo nativo
    #if android
    var widthToUse:Int = 0;
    var heightToUse:Int = 0;
    #else
    var widthToUse:Int = gameWidth;
    var heightToUse:Int = gameHeight;
    #end

    var game = new FlxGame(
        widthToUse,
        heightToUse,
        initialState,
        framerate,
        framerate,
        skipSplash,
        startFullscreen
    );

    #if debug
    addChild(fpsCounter);
    #end

    addChild(game);

    #if android
    FlxG.scaleMode = new flixel.system.scaleModes.RatioScaleMode(true); 
    #end

    /*
    FlxG.signals.postStateSwitch.add(function()
    {
        if (rainShader == null)
        {
            var rainFrag:String = sys.io.File.getContent("assets/shaders/Pioggia.frag");
            rainShader = new FlxRuntimeShader(rainFrag);

            rainShader.setFloat("uScale", 1.2);
            rainShader.setFloat("uIntensity", 0.4);
            rainShader.setFloat("uTime", 0.0);
            rainShader.setFloatArray("uRainColor", [0.55, 0.6, 0.65]);
            rainShader.setFloat("uSpeed", 190.0);
        }

        FlxG.game.setFilters([
            new ShaderFilter(rainShader)
        ]);

        if (!rainUpdateAdded)
        {
            rainUpdateAdded = true;

            FlxG.signals.preUpdate.add(function()
            {
                var t = rainShader.getFloat("uTime");
                t += FlxG.elapsed;

                if (t > 1000) t = 0; // protezione overflow

                rainShader.setFloat("uTime", t);
            });
        }
    });
    */
    FlxG.mouse.enabled = true;

    #if hxcpp_debug_server
    trace('hxcpp_debug_server attivato! Puoi ora connetterti al gioco con il debugger..');
    #else
    trace('hxcpp_debug_server disattivato! Questa build non supporta debugging.');
    #end
  }
}