package input;

import flixel.input.keyboard.FlxKey;

/**
 * 26/06/2026
 */
class Controls
{
    public static var player1 = new PlayerControls(
        0,
        FlxKey.A,
        FlxKey.D,
        FlxKey.W,
        FlxKey.S,
        FlxKey.ENTER,
        FlxKey.ESCAPE
    );

    public static var player2 = new PlayerControls(
        1,
        FlxKey.LEFT,
        FlxKey.RIGHT,
        FlxKey.UP,
        FlxKey.DOWN,
        FlxKey.ENTER,
        FlxKey.ESCAPE
    );

    public static function update():Void
    {
        player1.update();
        player2.update();
    }
}