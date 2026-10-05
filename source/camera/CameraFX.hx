package camera;

import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
// 01/07/2026
// Tipi di telecamera esclusivi della modalità VERSUS di New Super Mario Bros. DS
enum CameraAnimType 
{
    VERSUS_PIPE_ENTER;          // Ingresso/uscita dal tubo (piccolo sobbalzo verticale)
    VERSUS_GROUND_POUND;        // Schianto a terra (impatto verticale medio con rimbalzo)
    VERSUS_MEGA_MUSHROOM;       // Attivazione Mega Fungo (forte terremoto continuo mentre si cammina giganti)
    VERSUS_HIT_BY_SHELL;        // Colpito da un guscio o da un avversario (shake orizzontale rapido)
    VERSUS_GIANT_BLOCK_BREAK;   // Distruzione di un blocco grande (sobbalzo secco e assestamento)
}

class CameraFX 
{
    public static function play(type:CameraAnimType, durationMod:Float = 1.0):Void
    {
        // 1. SALVATAGGIO DEI VALORI ORIGINALI DELLA TELECAMERA
        // Memorizziamo lo stato esatto prima di applicare qualsiasi modifica
        var originalX:Float = FlxG.camera.scroll.x;
        var originalY:Float = FlxG.camera.scroll.y;
        var originalZoom:Float = FlxG.camera.zoom;
        var originalAngle:Float = FlxG.camera.angle;

        // Funzione di pulizia per resettare la telecamera allo stato iniziale perfetto
        var resetCamera = function() {
            FlxTween.globalManager.completeTweensOf(FlxG.camera);
            FlxTween.globalManager.completeTweensOf(FlxG.camera.scroll);
            FlxG.camera.scroll.set(originalX, originalY);
            FlxG.camera.zoom = originalZoom;
            FlxG.camera.angle = originalAngle;
        };

        // Interrompe i movimenti precedenti prima di iniziarne uno nuovo
        resetCamera();

        // 2. GESTIONE DEGLI EFFETTI ESCLUSIVI DELLA MODALITÀ VERSUS
        switch (type)
        {
            case VERSUS_PIPE_ENTER:
                // Movimento quando si entra/esce dai tubi per cambiare zona
                FlxTween.tween(FlxG.camera.scroll, {y: originalY + 15}, 0.08 * durationMod, {ease: FlxEase.quadOut, onComplete: function(_) {
                    FlxTween.tween(FlxG.camera.scroll, {y: originalY}, 0.08 * durationMod, {ease: FlxEase.quadIn, onComplete: function(_) {
                        resetCamera(); // Reset di sicurezza alla fine
                    }});
                }});

            case VERSUS_GROUND_POUND:
                // Lo schianto a terra per colpire l'avversario o rompere i blocchi
                FlxG.camera.shake(0.012, 0.15 * durationMod);
                FlxTween.tween(FlxG.camera.scroll, {y: originalY + 25}, 0.05 * durationMod, {ease: FlxEase.quadOut, onComplete: function(_) {
                    FlxTween.tween(FlxG.camera.scroll, {y: originalY - 10}, 0.08 * durationMod, {ease: FlxEase.quadInOut, onComplete: function(_) {
                        FlxTween.tween(FlxG.camera.scroll, {y: originalY}, 0.05 * durationMod, {ease: FlxEase.quadIn, onComplete: function(_) {
                            resetCamera();
                        }});
                    }});
                }});

            case VERSUS_MEGA_MUSHROOM:
                // Il terremoto massiccio quando un giocatore diventa gigante col Mega Fungo
                // Usiamo lo shake nativo impostando un timer di reset preciso al millisecondo
                FlxG.camera.shake(0.025, 0.6 * durationMod);
                
                // FlxG.camera.shake non ha una callback nativa comoda di fine effetto, 
                // quindi usiamo un timer/tween vuoto per forzare il reset perfetto allo scadere del tempo
                FlxTween.num(0, 1, 0.6 * durationMod, {onComplete: function(_) {
                    resetCamera();
                }});

            case VERSUS_HIT_BY_SHELL:
                // Quando vieni colpito da un guscio lanciato dall'altro giocatore (Sussulto X)
                FlxG.camera.shake(0.015, 0.2 * durationMod);
                FlxTween.tween(FlxG.camera.scroll, {x: originalX + 20}, 0.04 * durationMod, {ease: FlxEase.quadOut, onComplete: function(_) {
                    FlxTween.tween(FlxG.camera.scroll, {x: originalX - 15}, 0.06 * durationMod, {ease: FlxEase.quadInOut, onComplete: function(_) {
                        FlxTween.tween(FlxG.camera.scroll, {x: originalX}, 0.04 * durationMod, {ease: FlxEase.quadIn, onComplete: function(_) {
                            resetCamera();
                        }});
                    }});
                }});

            case VERSUS_GIANT_BLOCK_BREAK:
                // Impatto dovuto alla distruzione dei grandi blocchi di mattoni o blocchi item speciali
                FlxTween.tween(FlxG.camera.scroll, {y: originalY - 18}, 0.06 * durationMod, {ease: FlxEase.quadOut, onComplete: function(_) {
                    FlxTween.tween(FlxG.camera.scroll, {y: originalY + 8}, 0.06 * durationMod, {ease: FlxEase.quadInOut, onComplete: function(_) {
                        FlxTween.tween(FlxG.camera.scroll, {y: originalY}, 0.04 * durationMod, {ease: FlxEase.quadIn, onComplete: function(_) {
                            resetCamera();
                        }});
                    }});
                }});
        }
    }
}