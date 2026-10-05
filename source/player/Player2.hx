package player;

import input.Controls;
/**
 * data: 26/06/2026
 */
class Player2 extends Player
{
    public function new(x:Float, y:Float)
    {
        super(
            x,
            y,
            Controls.player2,
            CharacterDatabase.CHARACTERS[CharacterSelection.player2]
        );

        setGraphicSize(280, 360);
        updateHitbox();
    }
}