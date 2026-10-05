package player;

import input.Controls;
/**
 * data: 26/06/2026
 */
class Player1 extends Player
{
    public function new(x:Float, y:Float)
    {
        super(
            x,
            y,
            Controls.player1,
            CharacterDatabase.CHARACTERS[CharacterSelection.player1]
        );

        setGraphicSize(280, 320);
        updateHitbox();
    }
}