package;

import sys.FileSystem;
import sys.io.File;
import StringTools;

class GeneraTreemap {
    static inline var SOURCE_PATH:String = "source";

    static function main() {
        // --- 1. DEBUG INIZIALE ---
        Sys.println("-------------------------------------------");
        Sys.println(" INIZIO ANALISI SORGENTI: VERSUS 2026");
        Sys.println("-------------------------------------------");

        if (!FileSystem.exists(SOURCE_PATH)) {
            Sys.println("[ERRORE] La cartella '" + SOURCE_PATH + "' non è stata trovata.");
            return;
        }

        // Variabili per i dati del grafico
        var labels:Array<String> = ["VERSUS_2026_SOURCE"];
        var parents:Array<String> = [""];
        var values:Array<Float> = [0];
        
        var nodiRegistrati:Map<String, Bool> = new Map();
        nodiRegistrati.set("VERSUS_2026_SOURCE", true);

        // Contatori per Debug Terminale
        var contatoreFunzioni:Int = 0;
        var fileAnalizzati:Int = 0;
        var contatoreCartelle:Int = 0;
        var totaleLineeCodice:Int = 0;

        // --- 2. FUNZIONE RECURSIVA ---
        function analizzaCartella(path:String, parentNode:String) {
            Sys.println(" > Scansione cartella: " + path);
            
            for (item in FileSystem.readDirectory(path)) {
                var itemPath = path + "/" + item;
                
                if (FileSystem.isDirectory(itemPath)) {
                    contatoreCartelle++;
                    var folderNodeId = parentNode + "/" + item;
                    
                    if (!nodiRegistrati.exists(folderNodeId)) {
                        labels.push(folderNodeId);
                        parents.push(parentNode);
                        values.push(0);
                        nodiRegistrati.set(folderNodeId, true);
                    }
                    analizzaCartella(itemPath, folderNodeId);
                    
                } else if (StringTools.endsWith(item, ".hx")) {
                    fileAnalizzati++;
                    var nomeClasse = item.substring(0, item.length - 3);
                    var classNodeId = parentNode + "/" + nomeClasse;
                    
                    if (!nodiRegistrati.exists(classNodeId)) {
                        labels.push(classNodeId);
                        parents.push(parentNode);
                        values.push(0);
                        nodiRegistrati.set(classNodeId, true);
                    }

                    var contenuto = File.getContent(itemPath);
                    var righe = contenuto.split("\n");
                    totaleLineeCodice += righe.length;
                    
                    var inFunzione = false;
                    var lineeFunzione = 0;
                    var nomeFunzioneCorrente = "";

                    for (riga in righe) {
                        riga = StringTools.trim(riga);
                        if (StringTools.startsWith(riga, "//") || StringTools.startsWith(riga, "*")) continue;

                        if (StringTools.contains(riga, "function ") && StringTools.contains(riga, "(")) {
                            if (inFunzione && nomeFunzioneCorrente != "") {
                                labels.push(classNodeId + "::" + nomeFunzioneCorrente + "()");
                                parents.push(classNodeId);
                                values.push(lineeFunzione);
                                contatoreFunzioni++;
                            }
                            var indexFunc = riga.indexOf("function ") + 9;
                            var indexParentesi = riga.indexOf("(", indexFunc);
                            if (indexParentesi != -1) {
                                var estratto = riga.substring(indexFunc, indexParentesi);
                                nomeFunzioneCorrente = StringTools.trim(estratto.split("<")[0]); 
                            }
                            if (nomeFunzioneCorrente == "" || StringTools.startsWith(nomeFunzioneCorrente, "new")) nomeFunzioneCorrente = "new";
                            lineeFunzione = 1;
                            inFunzione = true;
                        } else if (inFunzione) {
                            lineeFunzione++;
                            if (StringTools.startsWith(riga, "}")) {
                                labels.push(classNodeId + "::" + nomeFunzioneCorrente + "()");
                                parents.push(classNodeId);
                                values.push(lineeFunzione);
                                contatoreFunzioni++;
                                inFunzione = false;
                                nomeFunzioneCorrente = "";
                            }
                        }
                    }
                }
            }
        }

        // Avvio scansione
        analizzaCartella(SOURCE_PATH, "VERSUS_2026_SOURCE");

        // --- 3. DEBUG FINALE TERMINALE ---
        Sys.println("-------------------------------------------");
        Sys.println("[COMPLETATO]");
        Sys.println("- Cartelle trovate: " + contatoreCartelle);
        Sys.println("- File .hx letti:   " + fileAnalizzati);
        Sys.println("- Funzioni totali:  " + contatoreFunzioni);
        Sys.println("- Linee di codice:  " + totaleLineeCodice);
        Sys.println("-------------------------------------------");
        Sys.println("Generazione file HTML in corso...");

        var jsonLabels = haxe.Json.stringify(labels);
        var jsonParents = haxe.Json.stringify(parents);
        var jsonValues = haxe.Json.stringify(values);

        // --- 4. TEMPLATE HTML ---
        var htmlTemplate = '
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>Sorgenti VERSUS 2026</title>
    <script src="https://cdn.plot.ly/plotly-2.24.1.min.js"></script>
    <style>
        body { 
            margin: 0; padding: 0; 
            background-color: #0d1117; 
            color: #c9d1d9; 
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
            display: flex; flex-direction: column;
            height: 100vh; width: 100vw;
            overflow: hidden;
        }
        header {
            padding: 16px 20px;
            background-color: #161b22;
            border-bottom: 1px solid #30363d;
            flex-shrink: 0;
        }
        .title {
            font-size: 20px;
            font-weight: 600;
            color: #f0f6fc;
            margin-bottom: 6px;
        }
        .stats-bar {
            font-size: 13px;
            color: #8b949e;
            display: flex;
            gap: 15px;
            flex-wrap: wrap; /* Fondamentale per mobile */
            margin-bottom: 8px;
        }
        .stats-bar b { color: #58a6ff; }
        
        .legend {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 12px;
            color: #8b949e;
            flex-wrap: wrap;
        }
        .legend-item { display: flex; align-items: center; gap: 5px; }
        .box { width: 12px; height: 12px; border-radius: 2px; }
        .box.source { background-color: #238636; }
        .box.empty { background-color: #30363d; }

        #chart { 
            flex-grow: 1; 
            width: 100%;
            min-height: 0; /* Previene overflow */
        }

        /* Correzioni per schermi molto piccoli */
        @media (max-width: 480px) {
            header { padding: 12px; }
            .title { font-size: 16px; }
            .stats-bar { gap: 8px; font-size: 11px; }
            .legend { font-size: 10px; }
        }
    </style>
</head>
<body>
    <header>
        <div class="title">VERSUS 2026 source code progress</div>
        <div class="stats-bar">
            <span>Functions: <b>$contatoreFunzioni</b></span>
            <span>Files: <b>$fileAnalizzati</b></span>
            <span>Modules: <b>$contatoreCartelle</b></span>
            <span>Lines: <b>$totaleLineeCodice</b></span>
        </div>
        <div class="legend">
            <div class="legend-item"><div class="box source"></div> Haxe matched</div>
            <div class="legend-item"><div class="box empty"></div> unmatched</div>
            <span>(Rect size by LOC)</span>
        </div>
    </header>

    <div id="chart"></div>

    <script>
        var rawLabels = $jsonLabels;
        var cleanLabels = rawLabels.map(function(l) {
            if (l === "VERSUS_2026_SOURCE") return "source/";
            if (l.indexOf("::") !== -1) return l.split("::")[1];
            var p = l.split("/"); return p[p.length - 1];
        });

        var data = [{
            type: "treemap",
            ids: rawLabels,
            labels: cleanLabels,
            parents: $jsonParents,
            values: $jsonValues,
            branchvalues: "remainder",
            textinfo: "label",
            marker: { 
                colorscale: [
                    [0, "#161b22"],
                    [0.2, "#0e4429"],
                    [0.6, "#26a641"],
                    [1, "#39d353"]
                ],
                line: { width: 1, color: "#0d1117" }
            },
            hoverlabel: { bgcolor: "#1c2128", font: {color: "#adbac7"} },
            hovertemplate: "<b>%{id}</b><br>Lines: %{value}<extra></extra>"
        }];

        var layout = {
            paper_bgcolor: "#0d1117",
            plot_bgcolor: "#0d1117",
            margin: { t: 5, l: 5, r: 5, b: 5 },
            font: { color: "#c9d1d9" }
        };

        Plotly.newPlot("chart", data, layout, {
            responsive: true, 
            displayModeBar: false,
            doubleClick: "reset"
        });
    </script>
</body>
</html>';

        File.saveContent("index.html", htmlTemplate);
        Sys.println("Successo! File 'index.html' esportato con successo!");
    }
}