#lang deinprogramm/sdp/advanced
(require ;;lang/htdp-advanced
  "vmdefs.rkt"
  "stack.rkt"
  "operations.rkt"
  (only-in     racket
                set!
                [set! set-it!]))
;; defiitions for the machine and the pseudo-code
(provide compile-secd)
; die Elemente einer Liste von Listen aneinanderhängen
(: append-lists ((list-of (list-of %a)) -> (list-of %a)))
(define append-lists
  (lambda (list)
    (fold '() append list)))

;; The STACK

(define fun-app-flag #f)

(define term->machine-code ;; spielt hier diee Reihenfolge der cases eine Rolle?
  (lambda (term)
    (cond
    
      ((definition? (smart-first term))
       (list (make-define-def (first (rest term))
                              (term->machine-code/t
                               (first (rest (rest term))))              
                              )))
      
((fun-application?  term)
         (let ([var  (first (rest term))]
               [rest-code  (rest (rest term))])
           (begin
            (set-it! fun-app-flag #t)
          (let ([result (append (term->machine-code (first rest-code))
               (append (term->machine-code (smart-first (smart-rest rest-code)))    
                      (list (make-app-fun var))))])
            (begin
        (set-it! fun-app-flag #t)
            result
          )))))


 
          ((the-stop? term)
               (append    (list (make-stop))
                (term->machine-code (rest term))                    
                       ))
      

       ((var-symbol? term) (list (make-push! (list term) )))
       
 ((application? term)
       (begin
       (cond ((not fun-app-flag)
              (begin             
       (let ([result (append (term->machine-code (first term))
               (append (term->machine-code (smart-first (smart-rest term)))
                       (list (make-tailap ))))])
       
         result)))
             (else (begin
                       (set-it! fun-app-flag #f)
                     term)))
     
       ))

    
      ((abstraction? term)
       (list
        (make-abst (smart-first  (eval-param (rest term)))
                   (term->machine-code
                    (first (rest (rest term)))))))
      
      ((base? term)  (list (make-push! (list term) ))) 
  
      ((primitive-application? term)
       (append
        (append-lists
         (map term->machine-code/t (rest term)))
        (list (make-prim
               (smart-first term)
               2))))
      
      ((and (not (empty? term)) (cons? term)
            (cons? (rest term)) (not (empty? (rest term))))
       (append (term->machine-code/t (first term))
               (append (term->machine-code/t (first (rest term))))))
      
      ((empty? term)
       (list)
       )
      )))




; Term in Maschinencode übersetzen
;  in nicht-endrekursivem Kontext

(: term->machine-code/t (term -> machine-code))
(define term->machine-code/t
  (lambda (term)
    (cond

    
      ((definition?  (smart-first term))
       (list (make-define-def (first (rest term))
                              (term->machine-code/t
                               (first (rest (rest term))))           
                              )))      
     
 ((fun-application?  term)
         (let ([var  (first (rest term))]
               [rest-code  (rest (rest term))])
           (begin
            (set-it! fun-app-flag #t)
          (let ([result (append (term->machine-code/t (first rest-code))
               (append (term->machine-code/t (smart-first (smart-rest rest-code)))    
                      (list (make-app-fun var))))])
            (begin
        (set-it! fun-app-flag #t)
            result
          )))))



         ((the-stop? term)
               (append    (list (make-stop))
                (term->machine-code/t (rest term))                    
                       ))
       
        ((var-symbol? term)
       (list (make-push! (list term) )))
        
  ((application? term)
       (begin
       (cond ((not fun-app-flag)
              (begin             
       (let ([result (append (term->machine-code/t (first term))
               (append (term->machine-code/t (smart-first (smart-rest term)))
                       (list (make-ap ))))])
       
         result)))
             (else (begin
                       (set-it! fun-app-flag #f)
                     term)))
     
       ))

      
      ((abstraction? term)
       (list
        (make-abst (smart-first  (eval-param (rest term)))
                   (term->machine-code/t-t
                    (first (rest (rest term)))))))
      
      ((base? term)
       (list (make-push! (list term) )))
    
      ((primitive-application? term)
       (append
        (append-lists
         (map term->machine-code/t (rest term)))
        (list (make-prim
               (smart-first term)
               2))))
      
      ((and (not (empty? term)) (cons? term)
            (cons? (rest term)) (not (empty? (rest term))))
       (append (term->machine-code/t-t (first term))
               (append (term->machine-code/t-t (smart-first (smart-rest term))))))
      
      ((empty? term)
       (list)
       )
       
      )))

(: term->machine-code/t-t (term -> machine-code))

(define term->machine-code/t-t ;; spielt hier diee Reihenfolge der cases eine Rolle?
  (lambda (term)
    (cond

    
      ((definition? term)
       (list (make-define-def (first (rest term))
                              (term->machine-code/t
                               (first (rest (rest term))))            
                              )))
     
((fun-application?  term)
         (let ([var  (first (rest term))]
               [rest-code  (rest (rest term))])
           (begin
            (set-it! fun-app-flag #t)
          (let ([result (append (term->machine-code/t (first rest-code))
               (append (term->machine-code/t (smart-first (smart-rest rest-code)))    
                      (list (make-app-fun var))))])
            (begin
        (set-it! fun-app-flag #t)
            result
          )))))

       ((the-stop? term)
               (append    (list (make-stop))
                (term->machine-code/t-t (rest term))))
      
       ((var-symbol? term)
       (list (make-push! (list term) )))
       
  ((application? term)
       (begin
       (cond ((not fun-app-flag)
              (begin             
       (let ([result (append (term->machine-code/t (first term))
               (append (term->machine-code/t (smart-first (smart-rest term)))
                       (list (make-tailap ))))])
       
         result)))
             (else (begin
                       (set-it! fun-app-flag #f)
                     term)))
     
       ))
  
      ((abstraction? term)
       (list
        (make-abst (smart-first (eval-param (rest term)))
                   (term->machine-code/t-t
                    (first (rest (rest term)))))))
      
      ((base? term)  (list (make-push! (list term) )))
 
      ((primitive-application? term)
       (append
        (append-lists
         (map term->machine-code/t (rest term)))
        (list (make-prim
               (smart-first term)
               2))))
      
      ((and (not (empty? term)) (cons? term)
            (cons? (rest term)) (not (empty? (rest term))))
       (append (term->machine-code/t (first term))
               (append (term->machine-code/t (first (rest term))))))
      
      ((empty? term)
       (list)
       )
      )))

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
                                  (append
                      (term->machine-code/t (first term))
                     (append (term->machine-code/t (rest term))))
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

;;(check-expect (compile-secd '(((lambda (x) (lambda (y) (mul y  (add x y)))) 1) 2)) 3);; this works now
;;(check-expect (compile-secd '((lambda (x) (mul 5 x)) 2)) 10)
;;(check-expect (compile-secd '(lambda (x) (lambda (y) (div 120 (mul y  (add x y)))) 1) 2) 20)
;; FIXME have to fix multiple nested expressions

;; Ein kleinerAusblick auf die nächste mögliche Funktionalität
#;(check-expect (compile-secd '(define test-add3 (lambda (x)
                                                 (lambda (y)
                                                   (add x y)           
                                                   )))) 7)

#;(check-expect (compile-secd '(define mul-add3 (lambda (y)
                                                (lambda(fun)
                                                  (mul y ((test-add3 y) 9)))))) 8)

;; hier mussnoch ((fun arg) arg2)  abgedeckt werden
(check-expect (compile-secd'((define test-west
                                           (lambda (x)
                                             (lambda (y)
                                             (mul x y))))
                                         (define higher (lambda (u)
                                                          (lambda ()
                                                          (add 5 ((app-fun test-west u) 6))
                                                            )))
                                         (app-fun higher 10))) 42) ;; replace 42 the number of wisdom
(check-expect  (compile-secd'((define test-west
                                            (lambda (x)                                             
                                              (mul x 9) ))
                                          (define higher (lambda (u)
                                                             (add 5 (app-fun test-west u))
                                                             ))
                                          (app-fun higher 10)
                                          (app-fun higher 7) 
                                          )) 42) ;

(check-expect  (compile-secd'((define test-west
                                            (lambda (x)                                             
                                              (mul x 9) ))
                                          (define higher (lambda (u)
                                                             (add 5 (app-fun test-west u))
                                                             ))
                                          (app-fun higher 10)
                                         
                                          )) 42)

(check-expect (compile-secd '((lambda (x) (lambda (y) (add x y) 1) 2))) 3)
