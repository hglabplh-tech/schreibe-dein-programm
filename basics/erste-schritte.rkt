#lang racket/base
;;
(+ 8 9);; just for fun a very simple program

;; data types of scheme / racket
;; integer 


;;addition, multiplication, subtraction, division // Addition , Multiplikation, Subtraktion,  Division
(+ 8 9)
(* 6 7)
(- 10 3)
(/ 10 2)

;; eine erste einfache Funktion

(define (testit name vorname)
  (display (string-append "Mein name  ist:  " vorname ",  "  name )))

(testit "Glab "  " Abigail Sophie Jeanne" )

;; ein wenig syntaktischer Zucker (syntactic sugar)

(define (const-add)
  (+ eight three)) ;; Variablen statt den Konstanten direkt

;; eine erste einfache Funktion höherer Ordnung // First class function
;; so eine Funktion kann auch ein Parameter sein oder einer Variablen zugewiesen werden

(define higher-order (lambda (parameter)
                       (+ parameter 4 5)))

(define consumer (lambda (value higher-order-fun)
                   (- 10000 value (higher-order-fun 8)))) ;; hier wird die übergebene Funktion aufgerufen

(printf " \nThe value is: ~a \n"  (consumer 100 higher-order))

(define let-demo (lambda (in)
                   (let ([x 2]
                     [my-number (+ 8 9 )])
                     (* in my-number x)
                     )))

(let-demo 10)

;; eine Art Schönfinkeln :-)

(define add-three (lambda (num)
                   (+ three num)))

(define adder (lambda (operand)
                (+ operand (add-three operand))
                   ))
(adder 8)

;;Rekursion

(define (recursion a-list)
  (let recur-lab (
                  [temp-list a-list]
                  [result (list)]  )
    (if (not (null? temp-list ))
        (let ([res  (* (car temp-list) 10)])           
          (recur-lab (cdr temp-list) (append result (list res)))
          )
        result
        )))
