package input;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
/**
 * data: 26/06/2026
 */
class PlayerControls
{
    public var moveX(default, null):Float = 0;
    public var moveY(default, null):Float = 0;

    // JUST PRESSED
    public var leftPressed(get, never):Bool;
    public var rightPressed(get, never):Bool;
    public var upPressed(get, never):Bool;
    public var downPressed(get, never):Bool;

    // HELD
    public var left(get, never):Bool;
    public var right(get, never):Bool;
    public var up(get, never):Bool;
    public var down(get, never):Bool;

    // ACTIONS
    public var confirmPressed(get, never):Bool;
    public var cancelPressed(get, never):Bool;

    public var anyHorizontalPressed(get, never):Bool;
    public var anyVerticalPressed(get, never):Bool;

    public var useKeyboard:Bool;
    public var gamepadID:Int;

    public var keyboardLeft:Int;
    public var keyboardRight:Int;
    public var keyboardUp:Int;
    public var keyboardDown:Int;

    public var keyboardConfirm:Int;
    public var keyboardCancel:Int;

    public function new(
        gamepadID:Int,
        left:Int,
        right:Int,
        up:Int,
        down:Int,
        confirm:Int,
        cancel:Int)
    {
        this.gamepadID = gamepadID;

        keyboardLeft = left;
        keyboardRight = right;
        keyboardUp = up;
        keyboardDown = down;

        keyboardConfirm = confirm;
        keyboardCancel = cancel;
    }

    public var gamepad(get, never):FlxGamepad;

    function get_gamepad():FlxGamepad
    {
        return FlxG.gamepads.getByID(gamepadID);
    }

    // ------------------------
    // PRESSED
    // ------------------------

    function get_left():Bool
    {
        return FlxG.keys.anyPressed([keyboardLeft])
            || (gamepad != null && gamepad.pressed.DPAD_LEFT);
    }

    function get_right():Bool
    {
        return FlxG.keys.anyPressed([keyboardRight])
            || (gamepad != null && gamepad.pressed.DPAD_RIGHT);
    }

    function get_up():Bool
    {
        return FlxG.keys.anyPressed([keyboardUp])
            || (gamepad != null && gamepad.pressed.DPAD_UP);
    }

    function get_down():Bool
    {
        return FlxG.keys.anyPressed([keyboardDown])
            || (gamepad != null && gamepad.pressed.DPAD_DOWN);
    }

    // ------------------------
    // JUST PRESSED
    // ------------------------

    function get_leftPressed():Bool
    {
        return FlxG.keys.anyJustPressed([keyboardLeft])
            || (gamepad != null && gamepad.justPressed.DPAD_LEFT);
    }

    function get_rightPressed():Bool
    {
        return FlxG.keys.anyJustPressed([keyboardRight])
            || (gamepad != null && gamepad.justPressed.DPAD_RIGHT);
    }

    function get_upPressed():Bool
    {
        return FlxG.keys.anyJustPressed([keyboardUp])
            || (gamepad != null && gamepad.justPressed.DPAD_UP);
    }

    function get_downPressed():Bool
    {
        return FlxG.keys.anyJustPressed([keyboardDown])
            || (gamepad != null && gamepad.justPressed.DPAD_DOWN);
    }

    // ------------------------
    // ACTIONS
    // ------------------------

    function get_confirmPressed():Bool
    {
        return FlxG.keys.anyJustPressed([keyboardConfirm])
            || (gamepad != null && (gamepad.justPressed.A || gamepad.justPressed.START));
    }

    function get_cancelPressed():Bool
    {
        return FlxG.keys.anyJustPressed([keyboardCancel])
            || (gamepad != null && (gamepad.justPressed.B || gamepad.justPressed.BACK));
    }

    // ------------------------
    // HELPERS
    // ------------------------

    function get_anyHorizontalPressed():Bool
    {
        return leftPressed || rightPressed;
    }

    function get_anyVerticalPressed():Bool
    {
        return upPressed || downPressed;
    }

    // ------------------------
    // UPDATE
    // ------------------------

    public function update():Void
    {
        moveX = 0;
        moveY = 0;

        // Tastiera
        if (FlxG.keys.anyPressed([keyboardLeft]))
            moveX--;

        if (FlxG.keys.anyPressed([keyboardRight]))
            moveX++;

        if (FlxG.keys.anyPressed([keyboardUp]))
            moveY--;

        if (FlxG.keys.anyPressed([keyboardDown]))
            moveY++;

        // Controller
        var pad = gamepad;

        if (pad != null)
            {
                // Stick analogico
                if (Math.abs(pad.analog.value.LEFT_STICK_X) > 0.2)
                    moveX = pad.analog.value.LEFT_STICK_X;

                if (Math.abs(pad.analog.value.LEFT_STICK_Y) > 0.2)
                    moveY = pad.analog.value.LEFT_STICK_Y;

                // D-Pad
                if (pad.pressed.DPAD_LEFT)
                    moveX = -1;

                if (pad.pressed.DPAD_RIGHT)
                    moveX = 1;

                if (pad.pressed.DPAD_UP)
                    moveY = -1;

                if (pad.pressed.DPAD_DOWN)
                    moveY = 1;
            }

            // Normalizza il movimento diagonale
            if (moveX != 0 && moveY != 0)
            {
                var len = Math.sqrt(moveX * moveX + moveY * moveY);
                moveX /= len;
                moveY /= len;
            }
    }
}