#lang deinprogramm/sdp/advanced
(require "vmdefs.rkt"
         "stack.rkt"
          "operations.rkt")
;; defiitions for the machine and the pseudo-code
(provide compile-secd)
; die Elemente einer Liste von Listen aneinanderhängen
(: append-lists ((list-of (list-of %a)) -> (list-of %a)))
(define append-lists
  (lambda (list)
    (fold '() append list)))

;; The STACK



(define term->machine-code ;; spielt hier diee Reihenfolge der cases eine Rolle?
  (lambda (term)
    (cond
      ((symbol? term) (list (make-push! (list term) )))
      ((application? term)
       (append (term->machine-code (first term))
               (append (term->machine-code (first (rest term)))
                       (list (make-tailap)))))
      ((abstraction? term)
       (list
        (make-abst (first (first (rest term)))
                  (term->machine-code
                   (first (rest (rest term)))))))
      ((base? term)  (list (make-push! (list term) )))
      ((primitive-application? term)
       (append
        (append-lists
         (map term->machine-code/t (rest term)))
         (list (make-prim
               (primitive->pcode (first term))
               (length (rest term)))))))))

; Term in Maschinencode übersetzen
;  in nicht-endrekursivem Kontext
(: term->machine-code/t (term -> machine-code))
(define term->machine-code/t
  (lambda (term)
    (cond
      ((symbol? term)  (list (make-push! (list term) )))
      ((application? term)
       (append (term->machine-code/t (first term))
               (append (term->machine-code/t (first (rest term)))
                       (list (make-ap)))))
      ((abstraction? term)
       (list
      (make-abst (first (first (rest term)))
                  (term->machine-code/t-t
                   (first (rest (rest term)))))))
      ((base? term)
       (list (make-push! (list term) )))
      ((primitive-application? term)
       (append
        (append-lists
         (map term->machine-code/t (rest term)))
        (list (make-prim
               (primitive->pcode term)
               (length (rest term)))))))))

(: term->machine-code/t-t (term -> machine-code))

(define term->machine-code/t-t ;; spielt hier diee Reihenfolge der cases eine Rolle?
  (lambda (term)
    (cond
      ((symbol? term)   (list (make-push! (list term) )))
      ((application? term)
       (append (term->machine-code/t (first term))
               (append (term->machine-code/t (first (rest term)))
                       (list (make-tailap)))))
      ((abstraction? term)
        (list
        (make-abst (first (first (rest term)))
                  (term->machine-code/t-t
                   (first (rest (rest term)))))))
      ((base? term)  (list (make-push! (list term) )))
      ((primitive-application? term)
       (append
        (append-lists
         (map term->machine-code/t (rest term)))
        (list (make-prim
               (primitive->pcode (first term))
               (length (rest term)))))))))

(define new-abstract
  (lambda (sedc closure-sym)
    ( make-closure closure-sym
                   ( term->machine-code/t))
    ))

;; process input
; Aus Term SECD-Anfangszustand machen
(: inject-secd (term -> secd))
(define inject-secd
  (lambda (term)
    (make-secd empty
               the-empty-environment
               (term->machine-code/t term)
               empty)))

; bis zum Ende Zustandsübergänge berechne)


; Evaluationsfunktion zur SECD-Maschine berechnen
(: compile-secd (term -> (mixed var-value (one-of 'function))))

;;(check-expect (compile-secd '(+ 1 2)) 3)
;;(check-expect (compile-secd '(((lambda (x) (lambda (y) (+ x y))) 1) 2)) 3)
(define compile-stack (make-stack (list)))
(define compile-secd
  (lambda (term)    
    (define value 
                     (inject-secd term))
    
   
        (begin
          (compile-stack 'push! value )
          (make-ast
                compile-stack
                (secd-code value)
                empty
                (secd-environment value)
                empty)) 
        ))
(check-expect (compile-secd '(((lambda (x) (lambda (y) (+ x y))) 1) 2)) 3)
(check-expect (compile-secd '((lambda (x) (* 5 x)) 2)) 10)