package audio;

import flixel.FlxG;
import flixel.sound.FlxSound;
/**
 * Registro dove verranno iscritti tutti i suoni del gioco dal quale
 * sarà possibile richiamarli ogni qual volta e in ogni stato vi troviate.
 * 
 * autore@Francesco Pio Pipino
 * data: 23/06/2026
 */
class SoundTable
{
    /**
     * Iscrizione iniziale per ogni suono.
     */
    public static var START_GAME:FlxSound;

    public static function init():Void
    {
        /* SUONO INIZIO PARTITA */
        START_GAME = FlxG.sound.load("assets/AudioTable/START_GAME.ogg");
        START_GAME.looped = false;
    }
}