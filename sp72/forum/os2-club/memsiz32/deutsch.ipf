:userdoc.
:title.'Systemresourcen' Hilfe
:body.

:h1 res=1.Einführung
:i1.Einführung
:artwork name='memsize.bmp' align=center.
:p.
Dieses Programm zeigt verschiedene Informationen im Zusammenhang mit
Systemresourcen.  Die Anzeige wird einmal pro Sekunde angepaßt, sofern
das Programm hierfür CPU-Zeit erhält.  Die angezeigten Informationen sind:
:p.
:hp2.Datum/Zeit:ehp2. - Laufendes Datum und Uhrzeit in dem Format, wie
es die Länderspezifikation für Ihr System in dem COUNTRY-Eintrag Ihrer
CONFIG.SYS-Datei vorschreibt.
:p.
:hp2.Abgelaufene Zeit:ehp2. - Die Zeit, die seit dem letzten Neustart des
Computers abgelaufen ist.
:p.
:hp2.Verfügbarer Speicher:ehp2. - Der Betrag an verfügbarem virtuellem Speicher
laut Funktion :hp1.DosQuerySysInfo:ehp1., abzüglich dem freien Platz für die
Auslagerungsdatei.  Dies ist die Summe des freien Platzes im Speicher
und des freien Platzes innerhalb der Auslagerungsdatei.  Ich habe noch
keinen Weg herausgefunden, die beiden auseinanderzuhalten.
:p.
:hp2.Swap-Größe:ehp2. - Die augenblickliche Größe der
Auslagerungsdatei des virtuellen Speichers (SWAPPER.DAT). Um diese
Datei zu finden, wird die Datei CONFIG.SYS nach
dem SWAPPATH-Eintrag durchsucht.  Dieser Eintrag liefert den vollen
Namen des Verzeichnisses der Auslagerungsdatei und zeigt den minimalen
Speicherplatz an, der auf dem Laufwerk der Auslagerungsdatei frei
bleiben muß.
:p.
:hp2.Freier Swap-Platz:ehp2. -  Der Betrag des freien
Plattenplatz auf dem logischen Laufwerk der Auslagerungsdatei
abzüglich des minimalen freibleibenden Platzes. Diese Zahl
zeigt an, wie weit die Auslagerungsdatei im Bedarfsfall ausgedehnt
werden könnte.
:p.
:hp2.Spool-Größe:ehp2. - Der Betrag an Plattenplatz, der von
Spool-Dateien verbraucht wird.
:p.
:hp2.CPU-Last (%):ehp2. - Die ungefähre Prozentzahl der verfügbaren
CPU-Leistung, die in diesem Moment gebraucht wird.  Sie wird über die
vergangene Sekunde gemittelt.
:note.Diese Funktion und  PULSE behindern sich gegenseitig.
:p.
:hp2.Anzahl aktiver Tasks:ehp2. - Die Anzahl der Einträge in der
System-Fensterliste; das ist die Liste, die angezeigt wird,
wenn Sie CTRL+ESC drücken.
:note.Es werden nicht unbedingt alle Einträge in der System-Taskliste
in der Fensterliste angezeigt.  Einige können als `nicht anzuzeigen'
markiert sein.
:p.
:hp2.Insgesamt freier Plattenplatz:ehp2. - Die Summe des freien Platzes auf
allen Festplatten.
:p.
:hp2.Auf Laufwerk X frei:ehp2. - Der Betrag freien Speichers auf Laufwerk X.
:p.
Wie Sie schon gesehen haben, ist die Hilfeeinrichtung aktiv und die
existierenden Kommandos können über das System-Menü des Fensters
angesprochen werden.  Die folgenden Kommandos sind verfügbar:
:sl compact.
:li.:hpt.Werte speichern:ehpt.:hdref res=11.
:li.:hpt.Standardwerte:ehpt.:hdref res=12.
:li.:hpt.Ohne Rahmen:ehpt.:hdref res=13.
:li.:hpt.Konfiguration...:ehpt.:hdref res=14.
:li.:hpt.Produktinformation:ehpt.:hdref res=15.
:esl.:p.
Außer den schon beschriebenen Vorrichtungen akzeptiert das Programm
auch Kommandos von den OS/2 2.0-Programmen zur Farb- und Schriftartpalette.

:h1 res=11.Werte speichern (Menü-Option)
:i1.Werte speichern (Menü-Option)
Bei Selektion dieser Menü-Option speichert das Programm seine
augenblickliche Position und den Zustand des Rahmens.
Beim nächsten Programmstart wird das Fenster an der gleichen Position
und entweder mit oder ohne Rahmen erscheinen, entsprechend dem
gespeicherten Zustand.
:p.
:note.Dieses Kommando kann über F2 direkt ausgeführt werden.

:h1 res=12.Standardwerte (Menü-Option)
:i1.Standardwerte (Menü-Option)
Diese Menü-Option setzt die Schriftart- und Farbattribute des
Programms auf ihre Standardwerte zurück.

:h1 res=13.Ohne Rahmen (Menü-Option)
:i1.Ohne Rahmen (Menü-Option)
Diese Menü-Option verbirgt den Rahmen des Programmfensters, d.h. also
das System-Menü, den Titelbalken und den Knopf für Symbolgröße.  Mit
einem Doppelklick auf irgendeinen Mausknopf kann diese Option
umgeschaltet werden.  Da ich es für nützlich hielt, das Fenster
bewegen zu können, auch wenn der Rahmen verborgen ist, wurde das
Fenster so eingerichtet, daß es mit jedem Mausknopf verschoben werden
kann.
:p.
:note.Dieses Kommando kann über ALT+H direkt ausgeführt werden.

:h1 res=14.Konfiguration... (Menü-Option)
:i1.Konfiguration... (Menü-Option)
Bei Selektion dieser Menü-Option wird der
Konfigurations-Dialog des Programms angezeigt.
:p.
:note.Die Tastenkombination Alt+C führt dieselbe Funktion aus.

:h1 res=140.Konfiguration... (Dialog)
:i1.Konfiguration... (Dialog)
Dieses Dialog-Fenster zeigt die Liste der verfügbaren
Anzeigedaten an und erlaubt Ihnen, diejenigen auszuwählen, die
im Programmfenster enthalten sein sollen.
Auch die Optionen `Ohne Rahmen' und `Immer oberstes Fenster'
können hier ein- und ausgeschaltet werden. Schließlich kann
auch das Intervall für die Anpassung der Anzeige hier
angeschaut und geändert werden.
:p.
Nehmen Sie alle gewünschten Änderungen vor und drücken dann
die ENTER-Taste oder klicken auf den OK-Knopf, um die
Änderungen wirksam werden zu lassen.
:p.
Um den Dialog abzubrechen ohne irgendeine der vorgenommenen
Änderungen zu speichern, drücken Sie die ESC-Taste oder
klicken auf den `Abbruch'-Knopf.

:h1 res=15.Produktinformation (Menü-Option)
:i1.Produktinformation (Menü-Option)
Selektion dieser Option bewirkt die Anzeige der Produktinformation.

:h1 res=150.Produktinformation (Dialog)
:i1.Produktinformation (Dialog)
Das Dialogfenster zeigt den Namen des Programms, das zugehörige Symbol
und die Copyright-Information an.  Das Fenster kann verlassen werden,
indem man die Eingabetaste, die Leertaste oder ESC drückt oder auf den
OK-Knopf klickt.

:h1 res=99.Hilfe für Tasten
:i1.Hilfe für Tasten
Die folgenden Funktionstasten wurden für dieses Programm definiert:
:sl compact.
:li.F1 - Hilfe
:li.F2 - Werte speichern
:li.F3 - Ende
:li.Alt+H - Ohne Rahmen
:li.Alt+C - Konfiguration
:esl.:p.

:h1 res=9900.Initialisierungspfad setzen (Dialog)
:i1.Initialisierungspfad setzen (Dialog)
Dieser Dialog wird angezeigt, wenn das Programm seine
Initialisierungsdatei (INI) nicht finden kann.  Er fragt danach, wo
die Datei ist oder wo sie angelegt werden soll.
:p.
Nur ein gültiger
Verzeichnisname wird akzeptiert.  Wenn Sie den Namen eingegeben haben,
drücken Sie die ENTER-Tast oder klicken Sie auf den OK-Knopf, damit
das Programm fortfährt.
:p.
Wenn Sie die Initialisierungssequenz
abbrechen wollen, drücken Sie die ESC-Taste oder klicken auf den
`Abbruch'-Knopf.

:euserdoc.



