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
  (only-in     racket/base
               datum->syntax)
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
(: term->machine-code (term -> machine-code))
(define term->machine-code ;; spielt hier diee Reihenfolge der cases eine Rolle?
  (lambda (term)
    (cond
    
      ((definition? (smart-first term))
       (list (make-define-def (first (rest term))
                              (term->machine-code
                               (first (rest (rest term))))              
                              )))
      
        ((fun-application? term)
         (append
            (append-lists
         (map term->machine-code/t (reverse (rest term))))
            (list (make-app-fun))
        )) 
      
      ((begin-it?  term)
       (list (make-code-block 
              (term->machine-code
               (rest term))))              
       )
     
      ((where-condition? term)       
       (list (make-where
              (term->machine-code
               (first (rest term)))
              (term->machine-code
               (first (rest (rest term))))
              (term->machine-code
               (first (rest (rest (rest term)))
                      )))))

   

      ((is-where? term)      
       (append
        (list (make-conditions  (map 
                                 term->machine-code 
                                 (rest term))))))

      ((is? term)     
       (list (make-single-cond
              (term->machine-code
               (first (rest term)))
              (append
               (term->machine-code
                (first (rest (rest term)))) (list (make-break))))))

      ((heap-allocator? term)
       (append           
        (append-lists
         (map term->machine-code/t (rest term)))            
        (list (make-heap-alloc))))
            
            
     
      ((heap-assignment? term)
       (append           
        (append-lists
         (map term->machine-code/t (rest term)))
        (list (make-heap-set-at!))))
     

      ((heap-getter? term)
       (append          
        (append-lists
         (map term->machine-code/t (rest term)))            
        (list (make-heap-get-at))))

      ((var-symbol? term) (list (make-push! (list term) )))
       
      ((application? term)
       (let ([result (append (term->machine-code (first term))
                             (append (term->machine-code (smart-first (smart-rest term)))
                                     (list (make-tailap ))))])       
         result))
         

    
 

      ((abstraction? term)
       (begin
         (write-newline)
         ;; (write-string (symbol->string term ))
         (let* ([params (reverse (smart-first (rest term)))]
                [abstract-code  (make-abst
                                 (eval-param params)                      ;; look for the a´bstraction params
                                 (term->machine-code
                                  (smart-first
                                   (smart-rest
                                    (smart-rest term)))))])
           (begin
             ;;    (write-string (symbol->string params ))
             (more-params (rest-or-empty params)
                          abstract-code
                          0  abstract-code)))))
      
      
      
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
      
      ((fun-application? term)
         (append
            (append-lists
         (map term->machine-code/t (reverse (rest term))))
            (list (make-app-fun))
        )) 
      
         
      ((begin-it?  term)
       (list (make-code-block 
              (term->machine-code/t
               (rest term))))              
       )
      
      ((where-condition? term)       
       (list (make-where
              (term->machine-code/t
               (first (rest term)))
              (term->machine-code/t
               (first (rest (rest term))))
              (term->machine-code/t
               (first (rest (rest (rest term)))
                      )))))

   

          
      ((is-where? term)      
       (append
        (list (make-conditions  (map 
                                 term->machine-code/t
                                 (rest term))))))


      ((is? term)     
       (list (make-single-cond
              (term->machine-code/t
               (first (rest term)))
              (append
               (term->machine-code/t
                (first (rest (rest term)))) (list (make-break))))))
                           
           
      ((heap-allocator? term)
       (append           
        (append-lists
         (map term->machine-code/t (rest term)))            
        (list (make-heap-alloc))))
            
            
     
      ((heap-assignment? term)
       (append           
        (append-lists
         (map term->machine-code/t (rest term)))
        (list (make-heap-set-at!))))
     

      ((heap-getter? term)
       (append          
        (append-lists
         (map term->machine-code/t (rest term)))            
        (list (make-heap-get-at))))
      
       
      ((var-symbol? term)
       (list (make-push! (list term) )))
        
      ((application? term)
       (let ([result (append (term->machine-code/t (first term))
                             (append (term->machine-code/t (smart-first (smart-rest term)))
                                     (list (make-ap ))))])       
         result))
     
       

      
             
      ((abstraction? term)
       (begin
         (write-newline)
         ;; (write-string (symbol->string term ))
         (let* ([params (reverse (smart-first (rest term)))]
                [abstract-code  (make-abst
                                 (eval-param params)                      ;; look for the a´bstraction params
                                 (term->machine-code/t-t
                                  (smart-first
                                   (smart-rest
                                    (smart-rest term)))))])
           (begin
             ;;    (write-string (symbol->string params ))
             (more-params (rest-or-empty params)
                          abstract-code
                          0  abstract-code)))))
      
      
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
     
        ((fun-application? term)
         (append
            (append-lists
         (map term->machine-code/t (reverse (rest term))))
            (list (make-app-fun))
        )) 

      ((begin-it?  term)
       (list (make-code-block 
              (term->machine-code/t
               (rest term))))              
       )

      ((where-condition? term)       
       (list (make-where
              (term->machine-code/t
               (first (rest term)))
              (term->machine-code/t
               (first (rest (rest term))))
              (term->machine-code/t
               (first (rest (rest (rest term)))
                      )))))

      ((is-where? term)      
       (append
        (list (make-conditions  (map 
                                 term->machine-code/t
                                 (rest term))))))

                           
                           

      
      ((is? term)     
       (list (make-single-cond
              (term->machine-code/t
               (first (rest term)))
              (append
               (term->machine-code/t
                (first (rest (rest term)))) (list (make-break))))))
         
      ((heap-allocator? term)
       (append           
        (append-lists
         (map term->machine-code/t (rest term)))            
        (list (make-heap-alloc))))
            
            
     
      ((heap-assignment? term)
       (append           
        (append-lists
         (map term->machine-code/t (rest term)))
        (list (make-heap-set-at!))))
     

      ((heap-getter? term)
       (append          
        (append-lists
         (map term->machine-code/t (rest term)))            
        (list (make-heap-get-at))))
      
      ((var-symbol? term)
       (list (make-push! (list term) )))
       
      ((application? term)
       (let ([result (append (term->machine-code/t (first term))
                             (append (term->machine-code/t (smart-first (smart-rest term)))
                                     (list (make-tailap ))))])       
         result))
     
       

  

     ((abstraction? term)
       (begin
         (write-newline)
         ;; (write-string (symbol->string term ))
         (let* ([params (reverse (smart-first (rest term)))]
                [abstract-code  (make-abst
                                 (eval-param params)                      ;; look for the a´bstraction params
                                 (term->machine-code/t-t
                                  (smart-first
                                   (smart-rest
                                    (smart-rest term)))))])
           (begin
             ;;    (write-string (symbol->string params ))
             (more-params (rest-or-empty params)
                          abstract-code
                          0 abstract-code)))))
      
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

(define more-params
  (lambda (params first-abst count result)
    (let* ([reverted-params  params]
           )
  
      (if (and (empty? reverted-params))
          (list result)
               (let* ([next-abst  (make-abst
                                   (eval-param reverted-params)
                                   first-abst)]
                      [res next-abst])          
                 (append (more-params (rest reverted-params)
                              next-abst (+ count 1)  res              
               )))))))

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
               empty
               (make-heap (list)))))

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
           [content (datum->syntax #f (port->string  file-port))])
      ;;(string->symbol content)
      content
      )))

(define read-analyze-compile
  (lambda (source-fname)
    (let* ([content (read-the-file source-fname)]
           [include-section (first content)]
           [code-section (rest content)]
           )
      (begin
        (for-each (lambda (fname)
                    (read-analyze-compile fname))
                  include-section)
        (compile-secd code-section)      
        ))))

;; Diese Audrücke müssen erneut geprüft werden
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
                                                               (add 5 (apply-fun test-west u))
                                                               (add 5 (apply-fun test-west 12)))                                               
                                                  )))
                               ((apply-fun higher 6)))) 42) ;

#;(check-expect (compile-secd'((define test-west
                                 (lambda (x)                                 
                                   (mul x 18)))
                               (define higher (lambda (u)
                                                (lambda ()
                                                  (cond-branch (< u 17)
                                                               (add 5 (apply-fun test-west u))
                                                               (add 5 ((higher 10))))
                                                  )))
                               ((apply-fun higher 10)))) 185)

;; Einfacher Test für cond-branch
(check-expect
 (compile-secd'((define higher (lambda (x)
                                 (lambda ()
                                   (cond-branch (< x 11)
                                                (mul 5 (add 7 x))
                                                (add 5 ((apply-fun higher 10))))
                                   )))
                ((apply-fun higher 10))))185)




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
                ((apply-fun higher 10))
                ((apply-fun higher 19))
                ((apply-fun higher 22))
                ) ) 777)
#;(check-expect  (compile-secd'((define test-west
                                  (lambda (x)                                             
                                    (mul x 9) ))
                                (define higher (lambda (u)
                                                 (add 5 (apply-fun test-west u))
                                                 ))
                                (apply-fun higher 11)
                                (apply-fun higher 7) 
                                )) 42) ;

#;(check-expect  (compile-secd'((define test-west
                                  (lambda (x)                                             
                                    (mul x 9) ))
                                (define higher (lambda (u)
                                                 (add 5 (apply-fun test-west u))
                                                 ))
                                (apply-fun higher 10)
                                         
                                )) 42)

#;(check-expect (compile-secd '((lambda (x) (lambda (y) (add x y) 1) 2))) 3)

;; Ultimativer Test der Rekursion
(check-expect  (compile-secd
                '((define calc-base
                    (lambda (x)
                      (mul x (div ((apply-fun higher 5)) 2))
                      ))
                  (define test-west
                    (lambda (x)
                      (cond-branch (< u 9)
                                   (mul x 18)
                                   (add 2 (apply-fun calc-base 3)))))
                  (define higher (lambda (u)
                                   (lambda ()
                                     (cond-branch (< u 9)
                                                  (mul 5 (add 7 u))
                                                  (add (apply-fun test-west u) ((apply-fun higher 7))))
                                     )))
                  ((apply-fun higher 10))))  #t)

(check-expect  (compile-secd
                '((define allocator
                    (lambda (x)
                      (add (heap-alloc g 8)
                           (sub (mul x (heap-set-at! g 16))
                                (heap-get-at g))
                           )))
                  (define higher (lambda (x)                                             
                                   (cond-branch (< x 11)
                                                (mul 8 7)
                                                (add (apply-fun allocator 100) (apply-fun higher 10))
                                                )))
                  (apply-fun higher 10))) 185)

(check-expect  (compile-secd
                '((define allocator
                    (lambda (x)
                      (add (heap-alloc g 8)
                           (sub (mul x (heap-set-at! g 16))
                                (heap-get-at g))
                           )))
                  (define higher (lambda (x)
                                   (code-block
                                    (where-cond  
                                     (is? (== x 40)
                                          (add 3 4))
                                     (is? (== x 80)
                                          (sub x (apply-fun higher 10)))
                                     (is? (< x 11)
                                          (mul 8 7))
                                     (is? (> x 12)
                                          (add (apply-fun allocator 100) (apply-fun higher 10))
                                          ))
                                    (cond-branch (> x 1100)
                                                 (mul 3 90)
                                                 (add (apply-fun allocator 200) (apply-fun higher 110))
                                                 ))
                                   ))
                  (apply-fun higher 10))) 185)

(check-expect  (compile-secd
                '((define allocator
                    (lambda (x y z)
                      (add (heap-alloc g 8)
                           (sub (mul x (heap-set-at! g 16))
                                (heap-get-at g))
                           ))))) 8)

(check-expect  (compile-secd
                '((define allocator
                    (lambda (x)
                      ((lambda (y)
                         ((lambda (z)
                      (add (heap-alloc g 8)
                           (sub (mul x (heap-set-at! g 16))
                                (heap-get-at g))
                           )) 9)) 116))))) 45)

               (check-expect  (compile-secd
                '((define allocator
                    (lambda (x)
                      (add (heap-alloc g 8)
                           (sub (mul x (heap-set-at! g 16))
                                (heap-get-at g))
                           ))))) #f)

       (check-expect  (compile-secd
                '((define allocator
                    (lambda (x)
                      ((lambda ()
                      (add (heap-alloc g 8)
                           (sub (mul x (heap-set-at! g 16))
                                (heap-get-at g))
                           ))))))) 'last)

   (check-expect  (compile-secd
                '((define allocator
                    (lambda (x)
                      (lambda (y)
                         (lambda (y)
                      (add (heap-alloc g 8)
                           (sub (mul x (heap-set-at! g 16))
                                (heap-get-at g))
                           )))))
                  (apply-fun allocator 7 8 9))) 'lambda-test)