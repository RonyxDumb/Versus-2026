package audio;

import flixel.FlxG;
import flixel.sound.FlxSound;
/**
 * Registro dove verranno iscritti tutte le canzoni del gioco
 * sarà possibile richiamarle ogni qual volta e in ogni stato vi troviate.
 * 
 * autore@Francesco Pio Pipino
 * data: 02/07/2026
 */
class MusTable
{
    /**
     * Iscrizione iniziale per ogni musica
     */
    public static var BGM_COOP:FlxSound;
    public static var BGM_COOP_BONUS:FlxSound;
    public static var BGM_COOP_SKY:FlxSound;
    public static var BGM_COOP_8BIT:FlxSound;
    public static var BGM_COOP_RES:FlxSound;

    public static function init():Void
    {
        /* BGM PARTITA */
        BGM_COOP = FlxG.sound.load("assets/MusTable/BGM_COOP.ogg");
        BGM_COOP.looped = true;

        /* BGM BONUS PARTITA */
        BGM_COOP_BONUS = FlxG.sound.load("assets/MusTable/BGM_COOP_BONUS.ogg");
        BGM_COOP_BONUS.looped = true;

        /* BGM SKY PARTITA */
        BGM_COOP_SKY = FlxG.sound.load("assets/MusTable/BGM_COOP_SKY.ogg");
        BGM_COOP_SKY.looped = true;

        /* BGM 8BIT PARTITA */
        BGM_COOP_8BIT = FlxG.sound.load("assets/MusTable/BGM_COOP_8BIT.ogg");
        BGM_COOP_8BIT.looped = true;

        /* BGM RES PARTITA */
        BGM_COOP_RES = FlxG.sound.load("assets/MusTable/BGM_COOP_RES.ogg");
        BGM_COOP_RES.looped = true;
    }
}