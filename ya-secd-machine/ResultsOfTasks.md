# Die Lösungen der Aufgaben

### A-10 : erstellen wir doch als Hausafgabe diese Punkte für :


```scheme
(lambda (x) 

	(lambda (y)  
		(lambda (z)
			(mul z (add x y)) 
		12) 
			3) 
				7)))

```

#### A-10-1: Beschreibung der Funktionen und wo sie aufgerufen werden 

Die äußere Funktion enthält ihrersits wieder eine weitere Funktion beide Funktionen haben exakt eine Bindung. Es ist auch per Definition so dass die Basis Funktionen nur einen Parameter haben dürfen.
Die zweite Funktion hat auch wieder eine Bindung und enthält unsere dritte Funktion die alle Bindings die außen gemacht wurden nutzt um  (mul z (add x y))  auszuführen.

#### A-10-2: Beschreibung der Steps die ablaufen um das Ganze korrekt auszuführen

1. 


#### A-10-3: Graphische Darstellung der Entwicklung von SECD, Dump, Stack und Umgebung


