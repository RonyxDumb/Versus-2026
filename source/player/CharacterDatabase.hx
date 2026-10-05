package player;
/**
 * data: 24/06/2026
 * Table dei personaggi.
 * Da qui vengono caricati tutti i personaggi che possono essere selezionati in partita.
 */
class CharacterDatabase
{
    public static final CHARACTERS:Array<CharacterData> =
    [
        /**
         * Ragazzi del gruppo
         */
        new CharacterData("Alessandro D'antuono", "Shape/BetaAle"), // Alessandro  D'antuono
        new CharacterData("Cicclon", "Shape/BetaPriore"), // Vincenzo Priore
        new CharacterData("Adriano Lombardi", "Shape/BetaAdriano"), // Adriano Lombardi
        new CharacterData("Daniele Martucci", "Shape/BetaDaniele"), // Daniele Martucci
        new CharacterData("Vincenzo Rinaldi", "Shape/BetaCez"), // Vincenzo Rinaldi
        new CharacterData("Riot", "Shape/BetaPaki"), // Pasquale Rutigliano
        new CharacterData("Nicola Padula", "Shape/BetaNicola"), // Nicola Padula

        /**
         * Ragazze del gruppo
         */
        new CharacterData("Morena De Lorenzo", "Shape/BetaMorena"), // Morena De Lorenzo
        new CharacterData("Memy", "Shape/BetaEmily"), // Emily Tirinnanzi
        new CharacterData("Martina Pizzicoli", "Shape/BetaMartina"), // Martina Pizzicoli
        new CharacterData("Rita Di Benedetto", "Shape/BetaRita"), // Martina Pizzicoli

        /**
         * Placeholder
         */
        // new CharacterData("Mario", "Shape/BetaMario"),
        // new CharacterData("Luigi", "Shape/BetaLuigi")
    ];
}