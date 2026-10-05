#if desktop
package plugins;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import sys.FileSystem;
import sys.io.File;
/**
 * autore@ The Funkin' Team
 * Plugin tramite il quale cliccando F12 esegue uno screenshot che verrà salvato
 * nella cartella "/screenshots"
 */
class ScreenshotPlugin extends FlxBasic
{
    public static var instance(get, never):ScreenshotPlugin;
    static var _instance:Null<ScreenshotPlugin> = null;
    static function get_instance():ScreenshotPlugin
    {
        if (_instance == null)
        {
            _instance = new ScreenshotPlugin({});
        }
        return _instance;
    }

    public static final SCREENSHOT_FOLDER:String = 'screenshots';

    var flashSprite:Sprite;
    var flashBitmap:Bitmap;
    var previewSprite:Sprite;
    var outlineBitmap:Bitmap;
    var shotPreviewBitmap:Bitmap;

    var screenshotTakenFrame:Int = 0;
    var screenshotBuffer:Array<Bitmap> = [];
    var screenshotNameBuffer:Array<String> = [];

    public function new(params:Dynamic)
    {
        super();
        // setup flash effect
        flashSprite = new Sprite();
        flashSprite.alpha = 0;
        flashBitmap = new Bitmap(new BitmapData(FlxG.width, FlxG.height, true, FlxColor.WHITE));
        flashSprite.addChild(flashBitmap);
        FlxG.stage.addChild(flashSprite);

        // setup preview
        previewSprite = new Sprite();
        previewSprite.alpha = 0;
        outlineBitmap = new Bitmap(new BitmapData(Std.int(FlxG.width / 5) + 10, Std.int(FlxG.height / 5) + 10, true, 0xFFFFFFFF));
        outlineBitmap.x = 5;
        outlineBitmap.y = 5;
        previewSprite.addChild(outlineBitmap);
        shotPreviewBitmap = new Bitmap();
        shotPreviewBitmap.scaleX /= 5;
        shotPreviewBitmap.scaleY /= 5;
        previewSprite.addChild(shotPreviewBitmap);
    }

    public override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // Detect screenshot key press
        if (hasPressedScreenshot() && screenshotTakenFrame == 0)
        {
            screenshotTakenFrame++;
        }
        else if (screenshotTakenFrame > 1)
        {
            screenshotTakenFrame = 0;
            capture();
        }
        else if (screenshotTakenFrame > 0)
        {
            screenshotTakenFrame++;
        }
    }

    public static function initialize():Void
    {
        FlxG.plugins.addPlugin(new ScreenshotPlugin({}));
    }

    public function hasPressedScreenshot():Bool
    {
        // F12 takes a screenshot
        return FlxG.keys.justPressed.F12;
    }

    public function capture():Void
    {
        // Read pixels from the screen
        var shot:Bitmap = new Bitmap(BitmapData.fromImage(FlxG.stage.window.readPixels()));

        // Save immediately
        saveScreenshot(shot, 'screenshot-${Date.now().getTime()}', 0, false);

        // Show flash effect
        flashSprite.alpha = 1;
        FlxTween.tween(flashSprite, { alpha: 0 }, 0.15);

        // Show preview
        showFancyPreview(shot);
    }

    function showFancyPreview(shot:Bitmap):Void
    {
        shotPreviewBitmap.bitmapData = shot.bitmapData;
        shotPreviewBitmap.x = outlineBitmap.x + 5;
        shotPreviewBitmap.y = outlineBitmap.y + 5;
        shotPreviewBitmap.width = outlineBitmap.width - 10;
        shotPreviewBitmap.height = outlineBitmap.height - 10;

        FlxG.stage.addChild(previewSprite);
        previewSprite.alpha = 0;
        FlxTween.tween(previewSprite, { alpha: 1 }, 0.3, {
            onComplete: function(_) {
                new FlxTimer().start(1.25, function(_) {
                    FlxTween.tween(previewSprite, { alpha: 0 }, 0.3, {
                        onComplete: function(_) {
                            FlxG.stage.removeChild(previewSprite);
                        }
                    });
                });
            }
        });
    }

    function makeScreenshotPath():Void
    {
        if (!FileSystem.exists(SCREENSHOT_FOLDER))
        {
            FileSystem.createDirectory(SCREENSHOT_FOLDER);
        }
    }

    function encode(bitmap:Bitmap):ByteArray
    {
        return bitmap.bitmapData.encode(bitmap.bitmapData.rect, new PNGEncoderOptions());
    }

    function saveScreenshot(bitmap:Bitmap, baseName:String, screenShotNum:Int = 0, delaySave:Bool = true):Void
    {
        makeScreenshotPath();

        var path = '${SCREENSHOT_FOLDER}/${baseName}.png';

        var data:ByteArray = encode(bitmap);
        File.saveBytes(path, data);
        trace('Screenshot salvato: ' + path);
    }
}
#end