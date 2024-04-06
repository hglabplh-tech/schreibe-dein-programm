#lang deinprogramm/sdp/advanced
(require 
  "secd-vm-defs.rkt"
  "secd-compiler.rkt"
  "stack.rkt"
  "operations.rkt"
  "debug-out.rkt")


(define temp-stack (make-stack (list)))



(define process (lambda (ast)
                  (let* ([op-stack (ast-stack ast)]
                         [code (ast-code ast)]
                         [env (ast-env ast )]
                         [dump (ast-dump ast)]
                         [act-frame (first dump)]
                         [state (make-secd op-stack (make-stack (list)) env code dump)])
                    (begin
                      
                      (secd-step* state)))))


(define secd-step*
  (lambda (state)
    (if (and (empty? (secd-code state))
             (empty? (secd-dump state)))
        state
        (secd-step* (really-process state)) ) ))

(define secd-exec-prim
  (lambda (state)
    (if  (empty? (secd-code state))             
        (make-secd
                  (secd-stack state)
                   (secd-fun-stack state)
                   (secd-environment state)
                   (secd-code state)
                   (secd-dump state))
        (secd-exec-prim (really-process state)) ) ))


(define call-abstract-pop! (lambda (term op-stack)
                             (if (abst? (first term))
                                 (begin
                                   (op-stack 'pop!)
                                   (abst-code (first term)))
                                 term
                                 )
                             ))
(define really-process (lambda (state)
                         (define op-stack (secd-stack state))
                          (define fun-stack (secd-fun-stack state))
                         (define env (secd-environment state))
                         (define code (secd-code state))
                         (define dump (secd-dump state))
                         (begin
                           (if (not (empty? code))
                      
                           (cond                         
                             ((abst? (first code))
                              (begin
                                     (print-stack-env-code op-stack fun-stack env code  "debug call abstraction")
                                (let* ([param-var  (abst-variable (first code))]
                                      
                                              
                                      [the-closure  (make-closure
                                                     param-var
                                                     (abst-code (first code))                                                                           
                                                     env)])
                                  (begin
                                    (write-object-nl param-var)
                                    (write-string "there is NO closure ON stack.....")
                                    (op-stack 'push!  (make-stack-element 'param param-var))
                                    (write-string "push closure") 
                                    (fun-stack 'push! the-closure)
                                    (fun-stack 'print-stack)
                                    (write-object-nl "temp stack content")
                                    (temp-stack 'print-stack)                                  
                            
                                         
                                        
                                    (write-object-nl "temp stack content")
                                    (temp-stack 'print-stack)
                                    (op-stack 'print-stack)
                                    (make-secd
                                     op-stack
                                     fun-stack
                                     env
                                     ;;(closure-code the-closure)
                                     (rest code)
                                     dump)))))
                                          
                                  
                                  
                        
                             ((op?  (first code))                     
                              (let ([val (first (op-params (first code)))])
                               (begin
                                  (cond ((base? val)
                                         (begin (write-newline)(write-string "get constant")
                                                (write-newline)
                                                (write-string  (number->string val))(write-newline)
                                                (write-string "push constant par: ")
                                                (write-string (number->string val))
                                                (write-newline)
                                                ((op-operation (first code)) op-stack (new-stack-element 'app val))       ;; NEW e have the proceedure
                                                ;; here it is a 'push!
                                                ) )
                                        
                                        ((var-symbol? val) ;; do the right order of income
                                         (begin
                                           (write-newline)
                                           (write-string "get var: ")
                                       
                                           (write-string " push variable par: ")
                                           (write-string (symbol->string val))
                                           (write-newline)
                                           (let ([bound-value  (lookup-environment
                                                                env
                                                                dump
                                                                val)])
                                          
                                               (cond
                                                 ((number? bound-value)
                                                     (begin
                                                     (write-string (number->string bound-value))
                                               ((op-operation (first code))  op-stack  (new-stack-element 'app
                                                                                              bound-value))
                                                 )))
                                             
                                                 
                                                   
                                                  
                                        
                                             ;; TODO: handle stack in the right way
                              
                                        )) ))
                                   
                                  (make-secd
                                   op-stack
                                   fun-stack
                                   env
                                   (rest code)
                                   dump)
                                  
                                  )))
                             
                             ((base? (first code))
                              (begin
                        
                                (op-stack 'push!(new-stack-element 'app (first code))) 
                                (make-secd
                                 op-stack
                                 fun-stack
                                 env
                                 (rest code)
                                 dump)
                                ))
                             
                           
                                     
                             ((where?-? (first code))
                                 (let*  (

                                         [fresh-stack (make-stack (list))]
                                         [dummy    ( cond
                                           ((> (op-stack 'size) 0)
                                               (fresh-stack 'push! (op-stack 'peekit))
                                            )
                                           (else (make-stack (list)))
                                           )]
                                         [cond-secd (make-secd
                                                             fresh-stack
                                                             fun-stack
                                                             env
                                                            (where?-condition (first code))
                                                            dump)])
                                   (begin
                                  
                                   (let* ([res-secd  (secd-exec-prim cond-secd)]
                                          [res-op-stack (secd-stack res-secd)]
                                          [res-fun-stack (secd-fun-stack res-secd)]
                                          [res-env (secd-environment res-secd)]
                                           [res-dump (secd-dump res-secd)]                                  
                                           [dummy (op-stack 'push! (res-op-stack 'peekit))]
                                          [cond-result (stack-element-value (op-stack 'pop!))]
                                         [the-code (if  cond-result
                                               (where?-if-branch (first code))
                                               (where?-else-branch (first code)))]
                                         [the-closure   (make-closure 'blubb
                                                                      the-code
                                                                      env)])
                                     
                                       (make-secd  op-stack
                                                    fun-stack
                                              (closure-environment the-closure)                                                                                  
                                             (closure-code the-closure)
                                             (cons
                                              ;;  (first stack))
                                              (make-frame op-stack fun-stack env (rest code))
                                              dump)
                                             ) ) ))
                                     )
                                   

                             ((prim? (first code))                    
                              (begin
                                (print-stack-env-code op-stack fun-stack env (rest code) "prim? enter op stack--> ")                           
                                 (write-object-nl (prim-operator (first code)))
                                 (let ([second-element  (stack-element-value (op-stack 'pop!))]
                                       [first-element (stack-element-value (op-stack 'pop!))])                                   
                                (op-stack 'push! (new-stack-element 'app
                                          (apply-primitive (prim-operator (first code))
                                                          (list first-element                        
                                                                 second-element))))
                                   )

                                (let ([secd-ret  (make-secd
                                 op-stack
                                 fun-stack
                                 env
                                 (rest code)
                                 dump)])
                                 (begin
                                    (print-stack-env-code op-stack fun-stack env (rest code) "state given by prim? --> ")
                                secd-ret)
                                  )))

                             ((define-def? (first code))
                              (begin
                                (write-newline)
                                (write-string "try to put to env: ")
                                (write-string (symbol->string (define-def-bind (first code))))
                                (write-newline)                               
                                (let* ([the-binding (define-def-bind (first code))]
                                       [the-value (define-def-value (first code))]                                     
                                       [extended-env (extend-environment
                                                      env
                                                      the-binding                                                          
                                                      the-value)])
                               
                                      (make-secd
                                       op-stack
                                       fun-stack
                                       extended-env
                                       (rest code)
                                       dump
                                  ))))
                                  
                                       
                                  
                                  
                               

                             ((app-fun? (first code))                             
                                (process-fun-app  state (first code)
                                )
                                )
                             
                             ((ap? (first code))
                              (let ([parameter-binding (stack-element-value (op-stack 'pop!))]
                                    [the-closure (fun-stack  'pop!)])                            
                                    
                              
                                (begin
                                      (print-stack-env-code op-stack fun-stack env code  "debug the ap?")
                                  (write-object-nl "Enter application ->")
                                  (op-stack 'print-stack)
                              
                                    
                                 
                                    
                                  (op-stack 'print-stack)                        
                                  (write-newline )                              
                                  (write-string "Parameter Binding: ")
                                  (write-string (number->string parameter-binding))
                                  (write-newline)

                                  (let ([extended-env 
                                                            (extend-environment
                                              (closure-environment the-closure)
                                              (closure-variable the-closure)
                                              parameter-binding)
                                                     ]
                                        [fresh-stack (make-stack (list))])
                                    (begin
                                       ( cond
                                           ((> (op-stack 'size) 0)
                                               (fresh-stack 'push! (op-stack 'peekit))
                                            )
                                           (else 'do-nothing)
                                           )
                                  (make-secd   fresh-stack
                                               (make-stack  (list))         
                                              extended-env                                   
                                             (closure-code the-closure)
                                             (cons
                                              ;;  (first stack))
                                              (make-frame op-stack fun-stack env (rest code))
                                              dump)
                                             ) ) ))))
                   
                             ((tailap? (first code)) ;; nach stack und environment sehen
                              (let ([closure (fun-stack 'pop!)]
                                    [fresh-stack (make-stack (list))]) ;; (define closure (first (rest stack)))
                                (begin                                  
                                        (print-stack-env-code op-stack fun-stack env code  "debug the tailap?")
                                            ( cond
                                           ((> (op-stack 'size) 0)
                                               (fresh-stack 'push! (op-stack 'peekit))
                                            )
                                           (else 'do-nothing)
                                           )
                                (make-secd fresh-stack
                                             fun-stack
                                           (extend-environment
                                            (closure-environment closure)
                                            (closure-variable closure)
                                            (op-stack 'pop!))    
                                           (closure-code closure)
                                           dump))))                         
                                 (else
                                  (leave-context op-stack fun-stack dump)
                                  ))     
   (leave-context op-stack fun-stack dump)))))

(define leave-context
  (lambda(op-stack fun-stack dump)
        (let* ([ frame (first dump) ]       
            [ret-stack (frame-stack frame)]
            )
                                (begin
                                  (write-object-nl "=============================== FINISH =====================")
                                  (write-object-nl "========THE FRAME FROM DUMP=====================")
                                  (debug-snap-frame frame "code is empty get from dump")
                                  (write-object-nl "========END THE FRAME FROM DUMP=====================")
                                  (write-object-nl "=============================== FINISH =====================")

                              ;;  (let ([ret-val (op-stack 'peekit)])
                                ;;  (begin
                                 ;;(ret-stack 'push!    ret-val)
                                  
                                    (begin
                                      ( cond
                                           ((> (op-stack 'size) 0)
                                               (ret-stack 'push! (op-stack 'peekit)
                                            ))
                                           (else 'do-nothing)
                                           )
                                
                                  (make-secd
                                   ret-stack ;; ATTENT
                                   fun-stack
                                   (frame-environment frame)
                                   (frame-code frame)
                                   (rest dump))
                                  ))
    )))

(define process-fun-app
  (lambda (secd-state fun-app-rec)
    (define code (secd-code secd-state))
     (define env (secd-environment  secd-state))
     (define op-stack (secd-stack secd-state))
     (define fun-stack (secd-fun-stack secd-state))
     (define dump (secd-dump secd-state))
  (begin
    (let*  ([inner-code (app-fun-code fun-app-rec)]
            [bind-var (app-fun-variable fun-app-rec)]
            [the-abst-code  (lookup-environment
                                                       env
                                                        dump
                                                        bind-var)]
             [the-closure  (make-closure
                                                      (abst-variable (first  the-abst-code))
                                                       (abst-code (first  the-abst-code))                                                                
                                                      env)]                           
             [call-state (make-secd op-stack fun-stack env inner-code dump)]
             [new-state (really-process call-state)]
            
            )
           (begin
           
                                    (debug-to-print-cl  the-closure "app-fun case")
                                    (write-newline)
                                    (write-string "after lookup:  ")
                                    (if (empty? the-closure)
                                        (write-string "no binding found")
                                        (write-string "binding found!!!!") 
                                     
                                        )
                                    (write-newline)
                                    (let* ([parameter-binding  (stack-element-value (op-stack 'pop!))]
                                           [parm-name (if (abst? (first the-abst-code))
                                                          (abst-variable (first the-abst-code))
                                                          'unknown)]
                                           [extended-env  (extend-environment
                                                           (closure-environment the-closure)
                                                           parm-name                                                          
                                                           parameter-binding)]
                                           [fresh-stack (make-stack (list))])
                                      (begin
                                        (op-stack 'print-stack)

                                        ( cond
                                           ((> (op-stack 'size) 0)
                                               (fresh-stack 'push! (op-stack 'peekit)))
                                            
                                           (else  'nothing))
                                     
                                        (make-secd
                                        fresh-stack 
                                        (make-stack (list))
                                        extended-env                                                                                                          
                                         (closure-code the-closure)
                                         (cons
                                          (make-frame op-stack fun-stack env (rest code))
                                          dump)
      )
                                
                               
                             
                                         )))))))
    
    
                   

(define eval-secd (lambda (ast)
                    (let* ([fresh-stack (lambda ()
                                          (make-stack (list)))]
                           [secd-mach (make-secd  (fresh-stack)  (fresh-stack) (ast-env ast) (ast-code ast) (ast-dump ast))]
                           [new-frame (make-frame (fresh-stack) (fresh-stack) (ast-env ast)  empty)]
                           [dump (append (list new-frame) (ast-dump ast))]
                           [result
                            (process (make-ast (fresh-stack) (ast-code ast) empty (ast-env ast) dump))])
                    
                      (stack-element-value ((secd-stack result) 'pop!)
                      ))))

;;(check-expect (eval-secd (compile-secd '((lambda (x) (mul 5 x)) 2))) 10)
;; this tiny scheme code is the level for the next step
(check-expect  (eval-secd  (compile-secd '((define test-west
                                            (lambda (x)                                             
                                              (mul x 9)))
                                          (define higher (lambda (u)
                                                           (add 5 (app-fun test-west u))
                                                           ))
                                          (app-fun higher 7))))  68)

(check-expect  (eval-secd   (compile-secd'((define test-west
                                            (lambda (x)                                             
                                              (mul x 9) ))
                                          (define higher (lambda (u)
                                                             (add 5 (app-fun test-west u))
                                                             ))
                                          (app-fun higher 10)
                                          (app-fun higher 7)
                                          ))) 68)

(check-expect  (eval-secd  (compile-secd'((define test-west
                                              (lambda (x)
                                                (lambda (y)
                                                  (mul x y))))
                                            (define higher (lambda (u)
                                                             (lambda (x-x-x)
                                                               (add ((app-fun test-west u) 6) 5)
                                                               )))
                                            ((app-fun higher 10) 0)))) 65)

(check-expect (eval-secd (compile-secd'((define test-west
                               (lambda (x)
                                 
                                   (mul x 18)))
                             (define higher (lambda (u)
                                              (lambda ((x-x-x))
                                                (cond-branch (== u 17)
                                                       (add 5 (app-fun test-west u))
                                                       (add 5 (app-fun test-west 12)))
                                                )))
                             ((app-fun higher 6) 0))))  221)

(check-expect (eval-secd (compile-secd'((define test-west
                               (lambda (x)
                                 
                                   (mul x 18)))
                             (define higher (lambda (u)
                                              (lambda ((x-x-x))
                                                (cond-branch (== u 17)
                                                       (add 5 (app-fun test-west u))
                                                       (add 5 (app-fun test-west 12)))
                                                )))
                             ((app-fun higher 17) 0)))) 311)

#;(check-expect (eval-secd (compile-secd'((define test-west
                               (lambda (x)
                                 
                                   (mul x 18)))
                             (define higher (lambda (u)
                                              (lambda ()
                                                (cond-branch (< u 17)
                                                       (add 5 (app-fun test-west u))
                                                       (add 5 ((higher 10))))
                                                )))
                             ((app-fun higher 10))))) 185)

#;(check-expect (eval-secd (compile-secd'((define test-west
                               (lambda (x)
                                 
                                   (mul x 18)))
                             (define higher (lambda (u)
                                              (lambda ()
                                                (cond-branch (< u 9)
                                                       (mul 5 (add 7 u))
                                                       (add 5 ((higher u))))
                                                )))
                             ((app-fun higher 10))))) 185)

(check-expect (eval-secd (compile-secd'((define test-west
                               (lambda (x)
                                 
                                   (mul x 18)))
                             (define higher (lambda (x)
                                             
                                                (cond-branch (< x 11)
                                                       (mul 5 (add 7 x))
                                                       (add 5 (app-fun higher 10))
                                                )))
                             (app-fun higher 15))))  90)
;(check-expect (eval-secd(compile-secd '(((lambda (x) (lambda (y) (mul y  (add x y)))) 1) 2))) 6)   
;;(check-expect (eval-secd(compile-secd '(((lambda (x) (lambda (y) (div 120 (mul y  (add x y) ) )) 1) 2)))) 20)



  ;; Ultimativer Test

(check-expect (eval-secd (compile-secd
                           '((define calc-base
                                             (lambda (x)
                                               (mul x (div (app-fun higher 5) 2))
                                               ))
                                        (define test-west
                               (lambda (t)
                                 (cond-branch (< t 9)
                                   (mul t 18)
                                  (add 2 (app-fun calc-base 3)))))
                             (define higher (lambda (u)
                                              
                                                (cond-branch (< u 9)
                                                       (mul 5 (add 7 u))
                                                       (add (app-fun test-west u) (app-fun higher 7)))
                                                ))
                             (app-fun higher 10)))) 162)

;; Verschachteltes where

#;(check-expect (eval-secd
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
                             ) )) 203)