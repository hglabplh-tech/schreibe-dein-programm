# Ein anderer Weg die SECD Maschine den SECD Compiler zu erklären:

## Was diese Abhandlung voraussetzt:
- Kenntnisse der Abläufe in funktionalen Sprachen oder Sprachelementen
- Grundkenntnisse über den Aufbau von Maschinen (Wie tickt z.B. ein PC was ist nötig dass er nützlich ist)
- Mindestens die ersten drei bis vier Kapiitel von Schreibe dein Programm
- Grundkenntisse Mathematik (Oberstufe)

## Zu den Übungsaufgaben
Die Übungsaufgaben sind mit A-1..n durchnummeriert. Die Lösungen stehen in ResultOfTasks.md 
zur Verfügung. Bitte tun sie sich den Gefallen und betrügen sie sich nicht. Der Lerneffekt geht sonst gegen Null bis darunter.

### Anmerkung: 
Ich verzichte hier an dieser Stelle bewusst auf Code Beispiele, da sich mancher dann vielleicht
zu sehr in Details der Implementierung verirrt. So ging es mir zumindest am Anfang (vor etwas über 30 Jahren)
Um diese Logik zu implementieren kann fast jede generelle Sprache verwendet werden... vorzugsweise  eine funktionale
Sprache Beispiele: SCHEME, LISP, Clojure, OCaml, Haskell... um nur ein paar zu nennen... wer Spaß an etwas mehr
Glue Code hat kann aber auch Java, C, C++,PL/1, Oder gar Cobol oder z.B.: Pascal oder für
hartgesottene Assembler nutzen. Funktionale Sprachen haben hier den Vorteil dass der
Kern der Logik klarer sichtbar ist.

## Ein wenig Historie:

Wir schreiben die Jahre 1960 -1970 die Informationstechnologie getrieben durch mathematische Theorien
unendliche Schwierigkeiten die es zu umschiffen gilt.

Nein sorry falscher Text zu viel "Star Trek" ;-)


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
standardmäßig der Wert der als erstes dort eingefügt wird auch als erster wieder entnommen
(FIFO: first in first out) wohingegen beim Stack der letzte eingeschobene Wert durch den POP als erster wieder vom Stapel
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

Bei der Endrekursion entfällt die Ablage auf dem Stack, da der rekursive Aufruf das letzte 'Statement' in der Funktion ist und man sich somit keinen Punkt in fder Funktion merken muss bei dem man wieder aufsetzt. 



**Anmerkung:** Für eine gute Beschreibung der Regeln und des Aufbaus einer SECD empfielt sich
[https://www.deinprogramm.de/dmda/secd.pdf](url)


#### Und nun ein Exempel zum Beweis dieser Ausführung

Wir hatten ja geshendass diese Überlegungen mit konstanten Werten wunderbar funktionieren. Nun kann man so natürlich keine flexible Logik verfassen.

Wie wäre es nun wenn wir folgendes hätten

x := 7
y := 3
z := 12 

nun würde - (* 12 (- 7 3)) zu (* z (- x y)) damit haben wir nun Variablen eingeführt

In einem funktionalen Programm wäre da so etwas wie:

- lambda <- x ;; x geht als Parameter in das äußerste lambda
-     lambda <- y ;; y ist dem lambda in dem äußeren lambda zugeordnet als Parameter
-        lambda <- z ;; und wieder eine Verschachtelung mit dem z als Parameter
-     -> {calculation} ;; siehe unten
-     :call-it  ;; lasst uns annehmen (: call-it ) ist der Aufruf einer anonymen closure // lambda definition
-     <- 12 ;; zugeordnet zur innersten definition
- 	   : call-it
-        <- 3 ;; zugeordnet zur mittleren definition
-           : call-it
-           <- 7 ;; zugeordnet der äußersten definition
- :end-prog --> Ende der Aufrufe und Definitionen 

--> die {calculation} ist nun (* z (- x y)).... 

Jetzt haben wir der Maschine ein Environment, die Fähigkeit zu lexikaler Bindung, und das Zusammenspiel zwischen Environment Aufrufen und Stack zuzufügen ... wofür wir dann auch den Dump benötigen wegen verschiedener Auswertungsebenen benötigen.

zu unserm etwas komplexeerem Beispiel

- wir haben ein Lambda mit dm Paramer 'x' dieser Parameter wird wie zu sehen ist mit der Zahl (beim Aufruf) 7 verknüpft und zwar durch die 'lexikale' Stellung .

Nun müssen wir das irgendwo festhalten... denken wir uns folgenden Aufbau der Umgebung (Environment)

Voraussetzungen: Die Umgebung kann mehrere Zuordnungen (Bindings) enthalten wie wäre es dafür mit -> :

- Binding Definition 
  

| Element des Binding  | Beschreibung                                                        |
|:---------------------|:--------------------------------------------------------------------|
| binding-variable     |  die Binding Variable ist etwas wie z.B.: ein Symbol / Bezeichner   |                
| binding-value        |  der Value ist das 'Datum' das dem Bezeichner zugeordnet wird.      |
| binding?             |  Prädikat welches sagt dies ist ein Binding (für die Logik notwendig|
| make-binding         |  Konstruktor für unser Datenkonstrukt.                              |


- So nun haben wir eine Definition mit der wir ein Binding (Zuordnung von Bezeichner zu Wert) abbilden können. Da es nun ziemlich wnig wäre nur ein Binding haben zu können machen wir doch Folgendes :

| Bindings (Sequenz von Bindings) | Darstellung                                    |
|:--------------------------------|:-----------------------------------------------|
| Ein Array eine Liste            | Die sequenzielle Speicherung mehrerer Bindings |


- Nun ist noch die Frage wann diese Zuordnung stattfindet und evtl. aufgelöst wird... :

Um diese Frage zu erörtern brauchen wir di Erklärung zum nächsten Begriff der hier auch schon aufgetaucht ist.

Closure : lambda <- x ; + x 3; : end-prog idst zunächst eine Definition.
Die Beschreibung dessen was hier ausgeführt werden soll. Diese Defiition ist im Grunde nichts weiter als eine statische Definition der Vorgehensweise (was soll passieren). 
Um nun diese. Definnition auszuführen müssen wir x (im Moment ein freischwebender Platzhalter) zuordnen dazu dient dann vom Ablauf her der Aufruf dieser Definition mit einer Konstanten.

lambda <- x ; + x 3; <- 6 (Aufruf des anonymen lambda mit der Zuordnung (lexikal) x = 6): end-prog

Hier kommt dann die Umgebung ins Spiel hier wird zum Zweck ddes Aufrufs ein Binding in der Umgebung abgelegt:

| Element des Binding  | Konkrete Zuordnung                                                  
|:---------------------|:--------------------------------------------------|
| binding-variable     |  x (Bezeichner)                                   |                
| binding-value        |  6 (Der Wert der durch den Aufruf zugeordnet wird |

Nun haben wir einen wichtigen Teil der Closure... definieren wir diese mal wie folgt können wir diese Closure zur Ausführung benutzen..

Mögliche Definition einer Closure:


| Element der Closure  | Beschreibung                                    |
|:---------------------|:------------------------------------------------|
| closure-variable     | Der Parameter der Funktion                      |
| closure-code         | Der auszuführende Code (+ x 3)                  |
| closure-environment  | Die Umgebung in der x = 6 festgehalten wird     |
| closure?             | Hier wieder ein Prädikat um Closure zu erkennen |
| make-closure         | Wie schon bei Binding ein Konstruktor.          |

Der Code enthält die statische Definition der Funktion (Higher Order Lambda)
Die Variable ist der Parameter in dem Fall der SECD ist es für ein Lambda nur ein Parameter
Das Environment enthält das beschriebene Binding.

Nun können wir den Code ausführen da zum statishen Code die Umgebung und die Parameterbindung hinzugekomen ist.

Jetzt haben wir die Zuordnung von Environment und Code fehlen noch Stack und Dump und deren Einordnung in der Maschine.

Dazu werden wir nun die 'Maschine' drfinieren dieses Konstrukt nennen wir einfach mal SECD:


| Element der 'Maschine'  | Beschreibung                                                     |
|:------------------------|:-----------------------------------------------------------------|
| secd-stack              | Der stack - Ablage Eingangs/Ausgangswerten von Instruktionen     |                         
| secd-environment        | Das Environment ist die Umgebung zur Ablage von Bindungen        |
| secd-code               | Hier ist der. statische Code enthalten augeführt über einen 'IP' |
| secd-dump               | Dump -> 'Generationen' von (Environment, Stack, Code) als Frames |
| secd?                   | Hier wieder ein Prädikat zur Bestimmung was wir hier haben       |
| make-secd               | Und hier auch wider ein Konstruktor                              |

Und hier noch was zum Dump - wie das Ebnvironment ist der Dump eine Sequenz von Werten (hier Frames) lassen wir doch ein Frame z.B. so aussehen:

(define-record frame
  make-frame frame?
  (frame-stack stack)
  (frame-environment environment)
  (frame-code machine-code))


| Element im Frame    | Beschreibung                                                       |
|:--------------------|:-------------------------------------------------------------------|
| frame-stack         | Der Stapel (Stack) wie er aussieht -> Zeitpunkt -> Frame-Konstrukt |
| frame-environment   | Die Umgebung als 'Snapshot' der Umgebung bei Frame-Konstrukt       |
| frame-code          | Der statische Code von der Stelle als das Frame erstellt wurde     |
| frame?              | Das Prädikat                                                       |
| make-frame          | Der Konstruktor                                                    |

So nun müssten wir alles definiert haben (Inhaltlich) was wir zur Erklärung benötigen




Wegen des Stack und dem Dump müssen wir nur das oben Beschriebene und die hier beschrieben Ausführung betrachten. Gehen wir das doch mal Schritt für Schritt durch... :


1. Zuerst natüürlich die Definition des Lambda (Higher Order Function) das wir ausführen wollen
2. Nun wollenn wir das Ganze zur Ausführung bringen dazu bauen wir uns unser Binding
3. Nach dem Binding brauchen wir den Wert des 'x' -> unser Parameter auf dem Stack
4. Wir bilden wie oben angeführt die Closure
5. Um die Closure auszuführen ordnen wir 'x' aus Ihrer Umgebung zu da bekommen wir die 6
6. Diese 6 kommt nun auf den Stack
7. Da wir die Ausführung über den Stack managen schieben wir auch die Closure (siehe oben) auf den Stack
8. Nun kommt die eigentliche Applikation -> jetzt wird die aktulle Umgebung in ein Frame (siehe oben) verpackt und in den Dump gehängt -> als jüngste 'Generation'
9. Ok jetzt wird der Stack initialisiert und eine leere aktuelle Umgebung mitgegeben und der Code wird in der Closure abgelegt (pointer auf die statische Definition)
10. Nun ist das 'x' an die 6 gebunden und die 6 ist auf dem Stack wo wir auch die Closure haben
11. Jetzt steht der Ausführung nichts mehr im Weg ausgeführt wird lambda <- x ; + x 3;
12. Nun kommt die Anweisun 'x' auf den Stack zu legen -> Parameter für die Berechnung
13. Nun kommt die Anweisung als nächsten Parameter die 3 auf den Stack zu legen
14. Und endlich kommt unsere Aktion -> hier eine primitive application -> '+'
15. Erst wird der Stack reverse gebaut siehe oben... dann wird der erste und der zweite Parameter vom Stack geholt (pop!) und die Addition wird ausgeführt
16. Die Werterückgabe erfolgt über den Stack auf dem nun das Ergebnis hier 9 abgelegt wird
17. Nun noch der SECD Maschinenzustand und der Dump. Wir haben den alten Zustand ja im Frame dort abgelegt
18. Jetzt 'mergen' wir den auf dem Frame abgelegten Stackzustand mit dem Momentanen Stand unseres Stack in der SECD 
18. Wir holen das Environment von davor vom Dump
19. Wir setzen die Ausführung dort fort wo der Stand des Frame- Code ist das heißt 1 nach dem 'return' 
20. Nun sind wir bereit für weitere Aufrufe von diesem oder anderen Lambdas von dieser Ebene aus

Nach dieser Beschreibung müssten wir ja auch obiges Beispiel mit 3 verschachtelten 'Higher Order' Funktionen dardstellen können... Lasst uns das doch mal versuchen:

Ich dachte ich würde damit auskommen keine spezielle Sprachezu benutzen und statt dessen Pseudo-Code zu schreiben, aber für das nun Folgende möchte ich doch besser Scheme / Lisp (racket) Syntax benutzen um alles effektiver darzustellen und zu schreiben.....

Denken wir uns dch mal folgenden Code



((define test-west
                                            
(lambda (x)                                             
                                              
(mul x 9) ))
                                          

(define higher 
(lambda (u)                                                             
(add 5 (app-fun test-west u))
                                                             
))

                                          
(app-fun higher 10)
                                          
(app-fun higher 7)
                                          
)))

```


A-1-1: Beschreibung der Funktionen und wo sie aufgerufen werden




- [x] Hier haben wir mehrere Aufrufe enthalten und können dann sehen wie das ganze in der SECD gehandhabt wird. Wir werden auch noch auf die dreifach verschachtelte Funktion zurückkommen. 

- Dies hier jetzt als etwas leichtere Kost:

Wir haben auch hier wieder eine Abstraktion (Higher Order) -> Bescghreibung der Logik
Hier ist das zum einen


```scheme
((define test-west
                                            
(lambda (x)                                             
                                              
(mul x 9) ))

und zum Anderen


 


(define higher 
(lambda (u)                                                             
(add 5 (app-fun test-west u))
                                                             
))
 
```


Das 'higher' ruft hier 'test-west' auf -> das geschieht in der Zeile 

    (app-fun test-west u) 

und 'higher' wird mit folgender Zeile aufgerufen

(app-fun higher 10)

nun kommt dieser Aufruf als erstes:

1. Die 10 wird mit dem 'u' verbunden u -> 10 und das Ganze wird auch dann in die Umgebung als Binding gelegt

2. Jetzt wird wieder eine Closure gebaut die in der Umgebung diese Bindung hat
3. Der Wert 10 sowie die Closure landen ebenso wie im vorigen Beispiel auf dem Stack. 
4. Nun wird wieder geswitched und der Code add 5 (app-fun test-west u)) wird aufgerufen.
5. Jetzt wird es lustig ... wir haben da eine 5 auf dem Stack und als zweiten Wert eine Funktion... HIIIILFEEE
6. -> um nun also auf die zweit Zahl auf dem Stack zu kommen müssen wir die Funktion ausführen die durch Ihre Berechnung den Wert auflöst.
7. Hierzu müssen wir ja genau den Parameter der Funktion an den Weert beim Aufruf binden...
8. Hier erhalten wir x -> u wobei u sich in 10 auflöst. Also haben wir in der Umgebung u -> 10 und x -> u (diesen Zwischenschritt sparen wir uns bei der Auflösung) also x -> 10
9. Nun da die Bindung da ist können wir fortfahren wie gehabt erst kommt x auf den Stack und dann die 9 das wieder umgedrreht gibt wieder 'x' = 10 als ersten Parameter und 9 als zweiten. 
10. Der Rest ist Geschichte die Operation mul(*) wird ausgeführt holt die zwei Parametr vom Stack und schiebt das Ergebnis (90) drauf.
11. Nach der Rückkehr wissen wir also unser zweiter Wert ist 90
12. Dann wird wie gehabt mit 'add' verfahren.
13. Nun kehren wir auch hier wieder zurück und holen die letzte Umgebung in Form des Frames ins hieer und jetzt als aktuelle Umgebung........ 

- Nun kommt der lecker Nachtisch:

A-10 : erstellen wir doch als Hausafgabe diese Punkte für :


```scheme
(lambda (x) 

	(lambda (y)  
		(lambda (z)
			(mul z (add x y)) 
		12) 
			3) 
				7)))
```


A-10-1: Beschreibung der Funktionen und wo sie aufgerufen werden

A-10-2: Beschreibung der Steps die ablaufen um das Ganze korrekt auszuführen 

A-10-3: Graphische Darstellung der Entwicklung von SECD, Dump, Stack und Umgebung



Ich hoffe das hat funktioniert ;-)	


                                                








