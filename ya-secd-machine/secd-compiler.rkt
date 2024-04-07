#lang deinprogramm/sdp/advanced
(require ;;lang/htdp-advanced
  "secd-vm-defs.rkt"
  "stack.rkt"
  "operations.rkt"
  "debug-out.rkt"
  racket/port
  (only-in     racket
               set!
               [set! set-it!])
    (only-in     racket
               open-input-file)
               )
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
                              (term->machine-code
                               (first (rest (rest term))))              
                              )))
      
      ((fun-application?  term)
       (list (make-app-fun (first (rest term))
                           (term->machine-code
                            (first (rest (rest term))))              
                           )))

     
    ((where-condition? term)       
       (list (make-where?
                    (term->machine-code
                     (first (rest term)))
                    (term->machine-code
                       (first (rest (rest term))))
                    (term->machine-code
                     (first (rest (rest (rest term)))
                     )))))

      ((heap-allocator? term)
   (cons           
                    (term->machine-code/t (rest term))
            
                     (list (make-heap-alloc))))
            
            
     
    ((heap-assignment? term)
     (cons           
                    (term->machine-code/t (rest term))
            
                     (list (make-heap-set-at!))))
     

    ((heap-getter? term)
      (cons           
                    (term->machine-code/t (rest term))
            
                     (list (make-heap-get-at))))

      ((var-symbol? term) (list (make-push! (list term) )))
       
      ((application? term)
       (let ([result (append (term->machine-code (first term))
                             (append (term->machine-code (smart-first (smart-rest term)))
                                     (list (make-tailap ))))])       
         result))
         

    
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
       (list (make-app-fun (first (rest term))
                           (term->machine-code/t
                            (first (rest (rest term))))              
                           )))
         

      
    ((where-condition? term)       
       (list (make-where?
                      (term->machine-code/t
                     (first (rest term)))
                    (term->machine-code/t
                       (first (rest (rest term))))
                    (term->machine-code/t
                     (first (rest (rest (rest term)))
                     )))))
    
    ((heap-allocator? term)
   (cons           
                    (term->machine-code/t (rest term))
            
                     (list (make-heap-alloc))))
            
            
     
    ((heap-assignment? term)
     (cons           
                    (term->machine-code/t (rest term))
            
                     (list (make-heap-set-at!))))
     

    ((heap-getter? term)
      (cons           
                    (term->machine-code/t (rest term))
            
                     (list (make-heap-get-at))))
      
       
      ((var-symbol? term)
       (list (make-push! (list term) )))
        
      ((application? term)
       (let ([result (append (term->machine-code/t (first term))
                             (append (term->machine-code/t (smart-first (smart-rest term)))
                                     (list (make-ap ))))])       
         result))
     
       

      
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
       (list (make-app-fun (first (rest term))
                           (term->machine-code/t
                            (first (rest (rest term))))              
                           )))

     ((where-condition? term)       
       (list (make-where?
                      (term->machine-code/t
                     (first (rest term)))
                    (term->machine-code/t
                       (first (rest (rest term))))
                    (term->machine-code/t
                     (first (rest (rest (rest term)))
                     )))))
         
     ((heap-allocator? term)
   (cons           
                    (term->machine-code/t (rest term))
            
                     (list (make-heap-alloc))))
            
            
     
    ((heap-assignment? term)
     (cons           
                    (term->machine-code/t (rest term))
            
                     (list (make-heap-set-at!))))
     

    ((heap-getter? term)
      (cons           
                    (term->machine-code/t (rest term))
            
                     (list (make-heap-get-at))))
      
      ((var-symbol? term)
       (list (make-push! (list term) )))
       
      ((application? term)
       (let ([result (append (term->machine-code/t (first term))
                             (append (term->machine-code/t (smart-first (smart-rest term)))
                                     (list (make-tailap ))))])       
         result))
     
       

  
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
               empty
               the-empty-environment          
               (append
                (append-lists
                 (map term->machine-code/t term)))
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

(define read-the-file
  (lambda (fname)
    (let* ([file-port (open-input-file fname)]
           [content (port->string  file-port #t)])
      (string->symbol content)
    )))

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
#;(check-expect (compile-secd'((define test-west
                               (lambda (x)
                                 
                                   (mul x 18)))
                             (define higher (lambda (u)
                                              (lambda ()
                                                (cond-branch (== u 17)
                                                       (add 5 (app-fun test-west u))
                                                       (add 5 (app-fun test-west 12)))                                               
                                                )))
                             ((app-fun higher 6)))) 42) ;

#;(check-expect (compile-secd'((define test-west
                               (lambda (x)                                 
                                   (mul x 18)))
                             (define higher (lambda (u)
                                              (lambda ()
                                                (cond-branch (< u 17)
                                                       (add 5 (app-fun test-west u))
                                                       (add 5 ((higher 10))))
                                                )))
                             ((app-fun higher 10)))) 185)

;; Einfacher Test für cond-branch
(check-expect
 (compile-secd'((define higher (lambda (x)
                                              (lambda ()
                                                (cond-branch (< x 11)
                                                       (mul 5 (add 7 x))
                                                       (add 5 ((app-fun higher 10))))
                                                )))
                             ((app-fun higher 10))))185)




;; Verschachteltes where
(check-expect
 (compile-secd'((define higher (lambda (x)
                                              (lambda ()
                                                (cond-branch (< x 11)
                                                       (mul 5 (add 7 x))
                                                       (cond-branch (> x 20)
                                                       (add 5 (mul 9 x))
                                                       (add x x))
                                                ))))
                             ((app-fun higher 10))
                              ((app-fun higher 19))
                             ((app-fun higher 22))
                             ) ) 185)
#;(check-expect  (compile-secd'((define test-west
                                  (lambda (x)                                             
                                    (mul x 9) ))
                                (define higher (lambda (u)
                                                 (add 5 (app-fun test-west u))
                                                 ))
                                (app-fun higher 11)
                                (app-fun higher 7) 
                                )) 42) ;

#;(check-expect  (compile-secd'((define test-west
                                  (lambda (x)                                             
                                    (mul x 9) ))
                                (define higher (lambda (u)
                                                 (add 5 (app-fun test-west u))
                                                 ))
                                (app-fun higher 10)
                                         
                                )) 42)

#;(check-expect (compile-secd '((lambda (x) (lambda (y) (add x y) 1) 2))) 3)

  ;; Ultimativer Test der Rekursion
 (check-expect  (compile-secd
                          '((define calc-base
                                             (lambda (x)
                                               (mul x (div ((app-fun higher 5)) 2))
                                               ))
                                        (define test-west
                               (lambda (x)
                                 (cond-branch (< u 9)
                                   (mul x 18)
                                 (add 2 (app-fun calc-base 3)))))
                             (define higher (lambda (u)
                                              (lambda ()
                                                (cond-branch (< u 9)
                                                       (mul 5 (add 7 u))
                                                       (add (app-fun test-west u) ((app-fun higher 7))))
                                                )))
                             ((app-fun higher 10))))  #t)

(check-expect (compile-secd'((define allocator
                               (lambda (x)
                                 
                                  (add (heap-alloc g 8) (heap-get-at g)
                                   )))           
                             (define higher (lambda (x)                                             
                                                (cond-branch (< x 11)
                                                       (heap-set-at! g 66)
                                                       (add 5 ((app-fun higher 10)))
                                                )))
                             ((app-fun higher 10))))185)
