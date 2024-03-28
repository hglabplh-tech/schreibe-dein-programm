# Ein anderer Weg die SECD Maschine den SECD Compiler zu erklären:

## Was diese Abhandlung voraussetzt:
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

## Ein wenig historie:

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

## Wie tickt ein Stack und was ist lexikale Bindung ?

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

[https://homepages.thm.de/~hg51/Veranstaltungen/PKR-15/Folien/pkr-02.pdf](url)

Sie finden auch tief gehende Erkllärungen in den Abhandlungen meines Informatiker-Kollegen Mike Sperber
z.B.: auf der Seite:
[https://www.deinprogramm.de](url)

Duiese Seite enttand im Zuge der Vermittlung der Informatik Grundkenntnisse und deren Weiterführung
an der Universität Tübingen. Diese Quellen sind sehr zuverlässig und exakt in der fachlichen Darstellung
und der dahinter verborgenen Theorie.

Ich möchte diesen Quellen nichts hinzufügen da diese Quellen alles über Bindung ausreichend ausführlich
und verlässlich erklären und es gäbe nur ein "Yet IN Other Words".

Nun haben wir einen Abriss über ie fachlichen Grundlagen um eine SECD Maschine einfach zu erklären.

## Die SECD Maschine:

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



## Hier ein kurzer Abriss über die Funktionale Arbeitsweise einer sogennanten SECD Maschine:

### Stack Verwendung und Zustandsänderungen / Übergänge


Eine Schwierigkeiten beim Entwickeln einer solchen Maschine ist das Stack Handling, ein sauberes Environment und die vernünftige Logik fütr (Zustands-) Übergänge...

#### Hier die wichtigsten Scenarien

1. Stack (The 'S' of SECD)

Erstes Szenario ist das ausführen von Operationen wie hier z.B.: Subtraktion:

Nehmen wir mal (7 - 3) alles klar gibt 4... aber ist das unserer Maschine auch ohne weiteres klar: Um etwas näher an die Maschine zu kommen erst mal eine andere Notation (- 7 3) wir ziehen einfach den Operator vor die Zahlen....

Nun haben wir es ja mit einer Stack Maschine zu tun und somit sind die Operanden (Argumente) vor der Aktion auf dem Stack. 

Also alles klar:

Stack: Hier kommt zum tragen dass wir die Source von links nach rechts interpretieren

| Stack     |
|:----------|
|     3     | 2 -> Hier kommt die 3
|     7     | 1 -> Hier kommt die 7

also sind wir doch glücklich !????

Das untere ist das erste Element das auf den Stack kam das obere das. zeweite..... und so fort

Nun ist ein Stack aber LIFO -> das letzte Element wird als erstes geholt also die 3 ...
Damit wäre das erste Argument die 3 und das zweite. die 7 daraus würde dann (- 3 7) Ups 
was nun. Wir revertieren den Stack so dass die Reihenfolge so aussieht

| Stack     |
|:----------|
|    7      |
|    3      |

und siee da die Reihenfolge beim Lesen ergibt wieder (- 7 3) 
Nun nimmt die Subtraction (z.B.: - ) die Zahlen und rechnet (wie in der Schule ;-)

Und nun wohin mit dem Ergebnis ? 

das Ergebnis wird gepusht also auf den Stack gelegt (die zwei. Argumente wurden vorher gepopt 
also vom Stack genommen... also steht da jetzt :


|  Stack    |
|:----------|
|     4     |


Diese Tatsache ist dann von besonderer Bedeutung wenn es eine Folgeberechnung gibt....

Lasst uns das mal betrachten:

2. Stack and Terms

Nun ist es ja ziemlich wenig nur eine Berechnung zu haben so könnten wir in der Notation für die Maschine z.B.: folgendes haben (* 12 (- 7 3)) alsu (12 * (7 - 3)) nun müssen wir betrachten ie dieses funktioniert:

- Die Reihenfolge der Auswertung 

Da wir für eine Berechnung in dieser Form erst mal den "Inneren Ausdruck" benötigen berechnen wir (- 7 3) die Art dieser Berechnung und was auf dm Stack passiert haben wir ja oben erörtert.
das heißt unser Stack sieht so aus:

- Die Entwicklung des Stack

|  Stack    |
|:----------|
|     4     |

Nun verwerten wir dieses Ergebnis und pushen den äußeren Wert 12 auf den Stack, das ergibt:

 
|  Stack    |
|:----------|
|     4     |
|    12     |

auch hier müssen wir einen "Stack reverse" einbauen so dass wir folgendes erhalten:

|  Stack    |
|:----------|
|    12     |
|     4     |

Unser Operator ist eine Multiplikation '*' also erhalten wir dann als Ergbnis

|  Stack    |
|:----------|
|     48    |

so und nun haben wir ganz toll mit Konstanten gerechnet im nächsten Abschnitt 
werden wir jetzt die für komplexe Logik unabdingbaren Variablen betrachten. Dies läuft mit den Begriffen Environment (Umgebung) und Binding

#### Was ist ein Environment und ein Binding in unserem Sinne. (Das 'E' von SECD)

Um Variablen (Bindungen von Symbolen / Strings / Adressen zu einem Datum) einzuführen müssen
wir einen Kontext haben in dem eine gültige Bindung möglich ist. Zu dem Konzept der Umgebung und der Bindung auch in Zusammenarbeit mit dem Stack später mehr. Da werden wir auch die Referenzierung einer Bindung durchgehen.
Jetzt aber erst mal ein kleiner Exkurs zur Logik- und Begriffserklärung....

1. Kleiner Exkurs / Komponenten und abgedeckte Funktionalität einer SECD Maschine

- Abstraktion definition einer Higher Order Funktion

Eine Abstraktion ist grob gesagt das Verfassen einer statischen Funktion die später mit eeinem Environment und dem aktuellen Stack zu einer Closure wird (Clojure = Higher Order mit Umgebung und aktuellem Maschinenstatus)

- Applikation (Funktionsaufruf // Closure)

Eine Applikation ist der Aufruf der Abläufe einer Abstraktion. Nun können wir nicht einfach nur den statischen Code aufrufen. Die Applikation tut folgendes:

Initialisierung des Stack
Setzen eines Environments (Umgebung) mit der gearbeitet wird
Setzen des nennen wir es mal 'IP' (Instruction Pointer) auf den auszuführenden Codes
Nun der eigentliche Aufruf

- Primitive Operationen (eigentlich auch so etwas wie eine Applikation)

Der Einfachheit halber gönnen wir uns eine Ausnahme zu einer Applikation um primitive Operationen wir +, *, -, / .... abzudecken:

Hier werden wie oben beschrieben die Argumente auf den Stack gelegt (mit der für die Operation gültigen Arity) und die Funktion wird ausgeführt wobei das Ergebnis dann auf dem Stack landet nachdem die Argumente vom Stack geholt wurden 

- Heap Speicher 

Heap Speichr ist im Gegensatz zum Environment ein zusätzlicher dynamisch angelegter Speicher der auch so etwas wie Bindungen hat (jedoch nicht lexikal)

- Basis Typen

Als Basis Typen nehmen wir zunächst Number? (Ganzzahl, Fließkomma Zahl, später evtl komplexe Zahlen ) ... dies reicht aber nicht ganz deshalb wollen wir danach noch zusätzlich Folgendes:

Character : ('Buchstaben / Sonderzeichen' / UTF8) aus diesem Datentyp können später Zeichenketten abgeleitet werden

Byte Typ: 8 Bit Number (Unsigned)

Speicherfeld (Array) : Ein Speicherfeld ist eine Menge eines bestimmten Daten Typ oder 'Mixed' 
auf die im Random Access (Freier Zugriff auf Elemente) über einen Index zugegriffen werden kann

Aus diesen Datentypen lassen sich dann alle anderen "höheren" Datentypen ableiten   

- Zuweisungen

Eine Ausnahme in der Logik sind Zuweisungen (Seiteneffekte / Zustandsbehaftet) 
Normalerweise bekommt eine Funktion Argumente die nicht verändert werden sondern es wird ein 'Result' gebildet das komplett auf frischem Speicher ausetzt. Bei Zuweisungen nennen wir es mal 'set! (Objekt, Wert) ' wird ein BESTEHENDER Wert geändert -> Speichermanipulation. Diws wird jedoch nur selten benötigt. 

- Bedingungen

Bedingungen können als Primitive Operationen dargestellt werden. Interessant ist hier der Verlauf im Code so müssen zwei verschieden Zweige weitergeführt werden. Die Auswahl welcher Zweig weitergeführt wird erfolgt über das Ergebnis der Bedingung. 



#### Code das ('C' von SECD)

Der Code wird als Sequenz dargestellt das heißt wie bei einer Liste wird hier Element für Element durchgegangen. Je nachdem ob eine Closure kommt oder eine bedingte Verzweigung wird die Auswertung an anderer Stelle fortgeführt.


#### Dump Rekursion / Continuation (Das 'D' von SECD)

Der Dump (bei dem ich mich wundere warum er Dump heißt) ist die Protokollierung der vorigen Environments, die bei Bedarf wieder von dort geholt werden. 
Dieese Environments werden zum Zweck der Ablage in sogenannte Frames verpackt:

Frame: Stack, Environment, Code 

Nun ist es so dass bei jedem Funktionsaufruf (Anwendung einer Closure) ein 'frisches' Environment (Umgebung) aus Stack, Environment, Code angelegt wird und das vorige Environment wird. in ein Frame gepackt und in den Dump 'vewrschoben'. 
WWenn nun diese Funktion endet wird der letzte eingestellte Frame vom Dump geholt um wieder dort aufzusetzen wo man vor dem Aufruf war. 

Bei einer Rekursion wird die 'normale' Rekursion und die sogenannte Endrekursion (Tail Recursion) unterschieden.

Bei der ersten Form wird der Rest des Codes und der Zustand vor dem Aufruf auf den Stack gelegt um dann an der richtigen Stelle fortzufahren.

Bei der Endrekursion entfällt die Ablage auf dem Stack, da der rekursive Aufruf das letzte 'Statement' in der Funktion ist unds man sich somit keinen Punkt in fder Funktion merken muss bei dem man wieder aufsetzt. 



**Anmerkung:** Für eine gute Beschreibung der Regeln und des Aufbaus einer SECD empfielt sich
[https://www.deinprogramm.de/dmda/secd.pdf](url)







  



