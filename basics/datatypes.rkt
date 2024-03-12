#lang racket/base
 (require expect/rackunit)
(define eight 8)
(define three 3)

;;Hier einige Beispieele für die definition von Variablen mit verschieden Typen

;; Hexadezimale Darstellong
(define hex-it #x00ffaa)
;; integer // Ganzzahl (32B)
(define int 76)
;; long // Ganzzal Long (64 B)
(define long 86876876876876)
;; float / double Fließkommazahlen
(define float 9868868.09790790)
;; strings // Zeichenketten
(define i-am-astring "hello here I am")
;; Listen und Paare 
(define a-list (list 5 5 6 7 8 9))
(define cons-it (cons 'reg 'free))
;; vector // Vektoren
(define vect  (vector 6 7 8 9 ))
;; symbol handling // Symbole ... Scheme Lisp spezifische Typen 
(define symbol-it 'I-Am-A-Sym)

;; Und hier der eigentliche Stoff lassem sie uns damit beginnen wann ist ein Datum gleich dem anderen
;; hier ein kleiner Auszug aus der acket Dokumentation:

;; Equality is the concept of whether two values are “the same.” Racket supports a few different kinds
;; of equality by default, although equal? is preferred for most uses.

;; Hier können wir entnehmen dass von den verschieden Funktionen für Gleichheit
;;meist equal? benutzt wird

;; equal? und ähnliche haben eine besondere Stellung man nennt sie Prädikate

(check-expect #t (equal? 'yes 'yes))
(check-expect #f (equal? 'yes 'no))
(check-expect #t (equal? (expt 2 100) (expt 2 100)))
(check-expect #t (equal? 2 2.0))
(check-expect #t (let ([v (mcons 1 2)]) (equal? v v)))
(check-expect #t (equal? (integer->char 955) (integer->char 955)))
(check-expect #t(equal? (make-string 3 #\z) (make-string 3 #\z)))
(check-expect #t(equal? #t #t))

;; das Prädikat eqv? unterscheidet sich an ein paar Stellen

(check-expect #t (eqv? 'yes 'yes))
(check-expect #f (eqv? 'yes 'no))
(check-expect #t (eqv? (expt 2 100) (expt 2 100)))
(check-expect #t (eqv? 2  2.0))
(check-expect #f (eqv? (mcons 1 2) (mcons 1 2)))
(check-expect #t (eqv? (integer->char 955) (integer->char 955)))
(check-expect  #f  (eqv? (make-string 3 #\z) (make-string 3 #\z)))
(check-expect #t(eqv? #t #t))

(check-expect #t (equal-always? 'yes 'yes))
(check-expect #f (equal-always? 'yes 'no) )
(check-expect #t (equal-always? (expt 2 100) (expt 2 100)))
(check-expect #t (equal-always? 2 2.0))
(check-expect #t (equal-always? (list 1 2) (list 1 2)))
(check-expect #t (let ([v (mcons 1 2)]) (equal-always? v v)))
(check-expect #f (equal-always? (mcons 1 2) (mcons 1 2)))
(check-expect #t (equal-always? (integer->char 955) (integer->char 955)))
(check-expect #f (equal-always? (make-string 3 #\z) (make-string 3 #\z)))
(check-expect #t (equal-always? (string->immutable-string (make-string 3 #\z))
                 (string->immutable-string (make-string 3 #\z))))
(check-expect  #t (equal-always? #t #t))

(check-expect #t  (eq? 'yes 'yes))
(check-expect #f  (eq? 'yes 'no))
(check-expect #t (eq? (* 6 7) 42))
(check-expect #f (eq? (expt 2 100) (expt 2 100)))
(check-expect #t (eq? 2 2.0))
(check-expect #t (let ([v (mcons 1 2)]) (eq? v v)))
(check-expect #f (eq? (mcons 1 2) (mcons 1 2)))
(check-expect #t  (eq? (integer->char 955) (integer->char 955)))
(check-expect #f (eq? (make-string 3 #\z) (make-string 3 #\z)))
(check-expect #t (eq? #t #t))