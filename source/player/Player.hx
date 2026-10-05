package player;

import flixel.FlxSprite;
import flixel.math.FlxMath;
import input.PlayerControls;

/**
 * data: 26/06/2026
 */
class Player extends FlxSprite
{
    public var moveSpeed:Float = 250;
    public var accelerationRate:Float = 1800;
    public var decelerationRate:Float = 2200;

    private var inputX:Float = 0;
    private var inputY:Float = 0;

    public var controls:PlayerControls;

    var baseScaleX:Float = 1;
    var baseScaleY:Float = 1;

    var walkTimer:Float = 0;

    // Variabile per salvare l'offset corretto generato da Flixel dopo il resize
    private var baseOffsetY:Float = 0;

    var baseY:Float;
    var baseX:Float;
    var isMoving:Bool = false;

    public function new(
        x:Float,
        y:Float,
        controls:PlayerControls,
        character:CharacterData
    )
    {
        super(x, y);

        this.controls = controls;

        loadGraphic(Paths.textures(character.texture));

        // 1. Scala prima la texture
        setGraphicSize(280, 320);

        // 2. Aggiorna l'hitbox (Flixel calcola l'offset nativo qui)
        updateHitbox();

        // 3. Salva l'offset di base per non perderlo durante il walk effect
        baseOffsetY = offset.y;

        // 4. Centra l'origine sulla hitbox reale
        origin.set(width * 0.5, height * 0.5);

        maxVelocity.set(moveSpeed, moveSpeed);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        handleInput();
        handleMovement(elapsed);
        updateFacing();
        handleWalkEffect(elapsed);
    }

    function handleInput():Void
    {
        inputX = controls.moveX;
        inputY = controls.moveY;

        isMoving = (inputX != 0 || inputY != 0);

        // Normalizzazione del vettore (eseguita una sola volta, pulita ed efficace)
        if (isMoving)
        {
            var len = Math.sqrt(inputX * inputX + inputY * inputY);
            if (len != 0) 
            {
                inputX /= len;
                inputY /= len;
            }
        }
    }

    function handleMovement(elapsed:Float):Void
    {
        if (inputX != 0)
            velocity.x += inputX * accelerationRate * elapsed;
        else
            velocity.x = FlxMath.lerp(
                velocity.x,
                0,
                decelerationRate * elapsed / moveSpeed
            );

        if (inputY != 0)
            velocity.y += inputY * accelerationRate * elapsed;
        else
            velocity.y = FlxMath.lerp(
                velocity.y,
                0,
                decelerationRate * elapsed / moveSpeed
            );

        velocity.x = FlxMath.bound(
            velocity.x,
            -moveSpeed,
            moveSpeed
        );

        velocity.y = FlxMath.bound(
            velocity.y,
            -moveSpeed,
            moveSpeed
        );
    }

    function handleWalkEffect(elapsed:Float):Void
    {
        if (isMoving)
        {
            walkTimer += elapsed * 12;

            // Il bounce ora somma il valore all'offset di base.
            // Nota: in Flixel, aumentare l'offset sposta la texture VERSO L'ALTO rispetto alla hitbox.
            var bounce:Float = Math.abs(Math.sin(walkTimer)) * 6; 

            offset.y = baseOffsetY + bounce;

            // Oscillazione della rotazione
            angle = Math.sin(walkTimer * 2) * 1.5;
        }
        else
        {
            walkTimer = 0;

            // Ritorno fluido ai valori di riposo (moltiplicato per elapsed così non si spacca a 144Hz+)
            offset.y = FlxMath.lerp(offset.y, baseOffsetY, 12 * elapsed);
            angle = FlxMath.lerp(angle, 0, 12 * elapsed);
        }
    }

    function updateFacing():Void
    {
        if (inputX < 0)
            flipX = true;
        else if (inputX > 0)
            flipX = false;
    }
}