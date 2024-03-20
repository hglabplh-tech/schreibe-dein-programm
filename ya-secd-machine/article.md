# Heading level 1
Ein anderer Weg die SECD Maschine den SECD Compiler zu erklären:

## Heading level 2
Was diese Abhandlung voraussetzt:
- Kenntnisse der Abläufe in funktionalen Sprachen oder Sprachelementen
- Grundkenntnisse über den Aufbau von Maschinen (Wie tickt z.B. ein PC was ist nötig dass er nützlich ist)
- Mindestens die ersten drei bis vier Kapiitel von Schreibe dein Programm
- Grundkenntisse Mathematik (Oberstufe)

Anmerkung: Ich verzichte hier an dieser Stelle bewusst auf Code Beispiele, da sich mancher dann vielleicht
zu sehr in Details der Implementierung verirrt. So ging es mir zumindest am Anfang (vor etwas über 30 Jahren)
Um diese Logik zu implementiren kann fast jede generelle Sprache verwendet werden... vorzugsweise  eine funktionale
Sprache Beispiele: Scheme Lisp Clojure OCaml Haskell... um nur ein paar zu nennen... wer Spaß an etwas mehr
Glue Code hat kann aber auch Java, C, C++,PL/1, Oder gar Cobol oder z.B.: Pascal oder für
hartgesottene Assembler nutzen. Funktionale Sprachen haben hier den Vorteil dass der
Kern der Logik klarer sichtbar ist.

## Heading level 2
Ein wenig historie:

Wir schreiben die Jahre 1960 -1970 die Informationstechnologie getrieben durch mathematische Theorien
unendliche Schwierigkeiten die es zu umschiffen gilt.

Nein sorry falscher Text zu viel "Star Treck" ;-)


Ein paar Worte:

Jetzt mal im Ernst es gab in dieser Zeit einige Vordenker die Logik für Probleme entwickelten die mit der damaligen
Hardware noch weit in den Sternen standen. Heute oh Wunder sind es genau diese Theorien die
uns das Leben leichter machen.
So ähnlich ist es auch mit der SECD Maschine und dem damit eng verbunden Lambda Kalkül und der
damit verbundenen Logik die sich mit dem Daten Konstrukt Stack (Stapel oder Haufen) darstellen lässt.
So #gibt es zum einen "Prozessoren" die mit Registern , Save Areas ... arbeiten und dann "Prozessoren / Maschinen (heute unter anderem unter dem Namen
VM (Virtual Machine) geläufig" die mit reinen Stack Operationen die Logik eines Programms aufbauen und intern betreiben.

Zurück in die 60er :

In den Jahren 1965 / 66 (Volume 9 / Number 3 / March, 1966) - "The next 700 programing languages by: P. J. Landin "
hatsich P. J. Landin sehr viele Gedanken gemacht um eine allgemeine Abstraktion von Programmiersprachen zu schaffen,
die dazu führen sollte mit diesem Konstrukt SECD (Stack Environment Code Dump) die Definition von Programmiersprachen
durch funktionale Beschreibung möglich zu machen, so dass man mit weig Maschienabhängigen Teilen durch Verwendung
des Lambda Kalkül jede beliebige Sprache beschrieben werden kann.

## Heading level 2
Wie tickt ein Stack und was ist lexikale Bindung ?
- Erst mal was ist ein Stack:
Stack ist ein so genannter Stapelpeicher ich kenne auch bisher außer am Mainframe kaum eine CPU
die nicht auch einen Stack hat. Ein Stack ist sozusagen das "Gegenteil" einer Queue bei der Queue wird
standardmäßig der Wert derals erstes dort eingefügt wird auch als erster wieder entnommen
(FIFO: first in first out) wohingegen beim Stack der letzte eingeschobene Wert durc den POP als erster wieder vom Stapel
genommen wird (LIFO: Last in first out). Nun wird in den meisten Sprachen intern so ein Stack genutzt um
Parameter zu managen. Hier ein Beispiel einer Addition

Push parm2 -> Push Parm1 -> Call Add (add nimmt) -> POP (Parm1) -> POP Parm2 -> gebe vom Stack
geholte Werte an ADD -> Führe ADD aus -> PUSH des result auf den Stack

Nun zur lexikalen Bindung von Bezeichnern in der Umgebung (Environment) :

Hier eine Seite auf der das kurz und knapp beschrieben ist.
Genauer Verfasser für mich nicht zuordenbar:

https://homepages.thm.de/~hg51/Veranstaltungen/PKR-15/Folien/pkr-02.pdf

Sie finden auch tief gehende Erkllärungen in den Abhandlungen meines Informatiker-Kollegen Mike Sperber
z.B.: auf der Seite:
https://www.deinprogramm.de

Duiese Seite enttand im Zuge der Vermittlung der Informatik Grundkenntnisse und deren Weiterführung
an der Universität Tübingen. Diese Quellen sind sehr zuverlässig und exakt in der fachlichen Darstellung
und der dahinter verborgenen Theorie.

Ich möchte diesen Quellen nichts hinzufügen da diese Quellen alles über Bindung ausreichend ausführlich
und verlässlich erklären und es gäbe nur ein "Yet IN Other Words".

Nun haben wir einen Abriss über ie fachlichen Grundlagen um eine SECD Maschine einfach zu erklären.

## Heading level 2
Die SECD Maschine:

Erst mal vorab ich willl mit meinen ausführungen nicht in Konkurrenz zu "Schreibe dein Programm" treten
sondern es nur von meiner eher praktischen Siichtweise aus  erklären.
Vor allem für die Fachkollegen die eher visuell denken. Aber ich kann niemand mit der grundlegenden Theorie verschonen.

So nun in medias res

Eine SECD Maschine  ist in der Lage das Lambda Kalkül im praktischen Sinne zu realisieren. Hier erst
mal ein paar Begriffe die wichtig sind.

- Bezeichner: Hierfür verwendet Scheme z.B. den Datentyp Symbol. Ein Bezeichner ist ein Name
der dazu verwendet wird in der Umgebung (dem Environment) einen daran gebundenen
Wert eindeutig wieder zu finden.
- Konstante , Value, Wert, Datum: Hier handelt es sich um den konkreten Wert der gbunden ist.

- Abstraction: Abstraktion ist die Beschreibung eines Algorithmus im weitesten Sinne in Lisp Dialekten auch
tatsächlich als Lambda  bezeichnet. Diese Abstraktion beschreibt erst mal was geschehen
soll und wird später zur Laufzeit mit der entsprechenden Umgebung ausgestattet die auf die
dahinterliegenden konkreten Werte mit denen agiert wird zurückführt (Thema Bindung)

- Applikation: Hier wird aus der Laufzeitumgebung (Stack Status, Environment Status IP (Instruction
                                                                                        Pointer (Code)))
   Bei deer Applikation werden die bis jetzt freien Bezeichner (Parameter) an ihren konkreten Wert
   gebunden und das Binding wird in das Environment gestellt.
   Der Wert vom Dump falls da schon etwas drin ist wird ggf. ins Environment genommen(Rekursion...)
   Hier wird jetzt mit dieser Voraussetzung eine  so genannte Closure gebastelt:
  Code + Environment + Stack + Dunp (vorige Generation des Environment die dann evtl. benötigt wird)
  Diese Clojure wird dann zur Ausführung gebracht. Ein entscheidender
Vorteil ist dass diese Clojure wiederum im Environment an einen Bezeichner
gebunden sein kann und wie eine normale Bindung b ehandelt werden kann als konkreter Wert zu dem
Bezeichner. Somit ist eine Closure auch als Parameter für eine weitere Clojure geeignet.

Eines ist zu beachten nach der Theorie ist für eine Abstraktion nur ein Parameeter zugelassen.
Diese Tatsache hält aber nicht auf da man durch Schönfinkeln (Currying) alles beliebig
ineinander verschachteln und variabel zusammensetzen lässt
Ein Vorteil ist auch dass nur ein sehr leiner Teil eines damit entwickelten Coompilers
maschinenabhängig ist... alles andere lässt sich durch die ineinandergreifende Definition von
mehreren Abstraktionen darstellen.

Es gibt eine Sprache in der versucht wurde die reine Theorie in die Praxis umzusetzen.
Der ursprünglich Quellcode ist in BCPL erfasst und die Sprache heißt PAL.
Eine frühe Implementierung liegt diesem Repository bei. 
Ebenso Landins Abhandkungebn und eine handschriftliche Definition der internen Abläufe die
nötig sind.

Am wichtigsten und von zentraler Bedeutung ist der Maschinenzustand der immer mitgeführt wird.
So hat man an dn wesentlichren Stellen immer einen "Snapshot" von Stack Environment Code und
Dump.
Immer wenn eine Applikation stattfindet wird dsas aktualle Environment in den Dump verfrachtet
und die anderen Zustände auch (Diese werden in einem sogenanntn Frame
eingepackt und in den Dump verfrachtet. Wird der ontext verlassen und man kehrt zurück
wird dieser Zustand wieder aus dem Dump genommen und reaktiviert.
Bei einer Rekursion z.B. bewirkt das dass eine Applikation auf die selbe Abstraktion beliebig
oft wiederholen lässt. Eine besondere Stellung hat die Tail Rekcursion
Endrekursion. Bei dieser ist der rekursive Aufruf ganz am Ende der Funktion. Damit muss man
sich hirer den vorigen Zustand nicht merken.


















Hier ein kurzer Abriss über die Funktionale Arbeitsweise einer sogennanten SECD Maschine:

