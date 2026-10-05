package transition;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIState;

class FNFState extends FlxUIState
{
	public static var disableNextTransIn:Bool = false;
	public static var disableNextTransOut:Bool = false;
    
    public var enableTransIn:Bool = true;
    public var enableTransOut:Bool = true;

    public static var dumpcachetuff:Bool = true;
    
    var transOutRequested:Bool = false;
    var finishedTransOut:Bool = false;

    var dumpAddt:Bool = true;

    public function new()
    {
        super();
    }

    override function create()
    {
        super.create();

		if (disableNextTransIn)
		{
			enableTransIn = false;
			disableNextTransIn = false;
		}
        
		if (disableNextTransOut)
		{
			enableTransOut = false;
			disableNextTransOut = false;
		}
        
		if (enableTransIn)
		{
			// trace("transIn");
			fadeIn();
		}
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    override public function startOutro(onOutroComplete:()->Void):Void
    {
        if (!enableTransOut)
        {
            onOutroComplete();
            return;
        }

        fadeOut(function()
        {
            onOutroComplete();
        });
    }

    function fadeIn()
    {
        subStateRecv(this, new DiamondTransSubState(0.5, true, function() { closeSubState(); }));
    }

    function fadeOut(finishCallback:()->Void)
    {
        subStateRecv(this, new DiamondTransSubState(0.5, false, finishCallback));
        
    }

    function subStateRecv(from:FlxState, state:FlxSubState)
    {
        if (from.subState == null)
            from.openSubState(state);
        else
            subStateRecv(from.subState, state);
    }
}