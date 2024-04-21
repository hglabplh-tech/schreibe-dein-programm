#lang deinprogramm/sdp/advanced
(require 
  "secd-vm-defs.rkt"
  "secd-compiler.rkt"
  "stack.rkt"
  "operations.rkt"
  "debug-out.rkt")

;;TODO :: make in all places like code-block and conditions real closure inits like in app-fun
;; enable break functionality
(define temp-stack (make-stack (list)))



(define process (lambda (ast)
                  (let* ([op-stack (ast-stack ast)]
                         [code (ast-code ast)]
                         [env (ast-env ast )]
                         [dump (ast-dump ast)]
                         [act-frame (first dump)]
                         [state (make-secd (make-stack (list) ) (make-stack (list)) env code (list) (make-heap (list)))])
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
          (secd-dump state)
          (secd-heap state))
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
                         (define heap-inst (secd-heap state))
                         (begin
                           (if (not (empty? code))
                               (begin
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
                                                                          
                                          (fun-stack 'push! the-closure)
                                          (fun-stack 'print-stack)                               
                                          (op-stack 'print-stack)                               
                                   
                                          (make-secd
                                           op-stack
                                           fun-stack
                                           env
                                           ;;(closure-code the-closure)
                                           (rest code)
                                           dump
                                           heap-inst)))))
                                          
                                  
                                  
                        
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
                                                                                                                   bound-value))))
                                                     (else
                                                      ((op-operation (first code))  op-stack  (new-stack-element 'app
                                                                                                                 val)))
                                                     )))
                              
                                               )
                                              ((single-cond? val)
                                               ((op-operation (first code))  fun-stack  val))
                                              )
                                        (debug-snap-stack op-stack "stack after push correct ???!!!???")
                                        (make-secd
                                         op-stack
                                         fun-stack
                                         env
                                         (rest code)
                                         dump
                                         heap-inst)
                                  
                                        )))

                                   ((conditions? (first code))
                                    (begin
                                      (write-object-nl "enter conditions -->")
                                        (write-object-nl (conditions-conds  (first code)))
                                    (make-secd
                                     op-stack
                                     fun-stack
                                     env
                                     (conditions-conds  (first code))                                  
                                     (cons
                                      (make-frame op-stack fun-stack env (rest code))
                                      dump)                                   
                                     heap-inst)))
                                   
                                   ((single-cond? (first code))
                                    
                                    (begin
                                      (write-object-nl "enter single cond case -->")
                                      (do-is  (first code) state)
                                     ))

                                   ((break? (first code))
                                    (let* ([ frame (first dump) ]       
                                           [ret-stack (frame-stack frame)])
                                      (begin
                                        (cond
                                          ((> (op-stack 'size)  0)
                                           (ret-stack 'push! (op-stack 'peekit) ;; herre was a 'peekit
                                                      ))
                                          (else 'do-nothing
                                                ))
                                        (make-secd
                                         op-stack
                                         (frame-fun-stack (first dump))
                                         (frame-environment (first dump))
                                         (frame-code (first dump))
                                         (rest dump)
                                         heap-inst
                                         )
                                        )))
                                    
                             
                                   ((code-block? (first code))                                    
                                    (closure-apply state (code-block-code (first code)))                                      
                                    )
                             
                                   ((base? (first code))
                                    (begin
                        
                                      (op-stack 'push!(new-stack-element 'app (first code))) 
                                      (make-secd
                                       op-stack
                                       fun-stack
                                       env
                                       (rest code)
                                       dump
                                       heap-inst)
                                      ))

                                   ((heap-alloc? (first code))
                                    (let* ([the-value  (stack-element-value (op-stack 'pop!))]
                                           [identifier (stack-element-value (op-stack 'pop!))]
                                           [act-value (lookup-heap-stor  heap-inst  identifier)])
                                      (begin
                                        (if (empty? act-value)
                                            (let ([new-heap-inst (extend-heap-stor heap-inst identifier the-value) ])
                                              (begin
                                                (op-stack 'push! (new-stack-element 'app the-value))
                                                (debug-snap-heap heap-inst "print heap in ALLOC")
                                                (make-secd
                                                 op-stack
                                                 fun-stack
                                                 env
                                                 (rest code)
                                                 dump
                                                 new-heap-inst)
                                                ))
                                            (make-secd
                                             op-stack
                                             fun-stack
                                             env
                                             (rest code)
                                             dump
                                             heap-inst)
                                            ))                              
                                      ))
                                  
                                   ((heap-set-at!? (first code))
                                    (let* ([the-value  (stack-element-value (op-stack 'pop!))]
                                           [identifier (stack-element-value (op-stack 'pop!))]
                                           [act-value (lookup-heap-stor  heap-inst  identifier)])
                                      (begin
                                        (if (not (empty? act-value))                                       
                                            (let ([heap-inst-new  (extend-heap-stor heap-inst identifier the-value)])
                                              (begin
                                                (debug-snap-heap heap-inst "print heap in SET")
                                     
                                                (extend-heap-stor heap-inst identifier the-value)
                                                (op-stack 'push! (new-stack-element 'app the-value)) 
                                                (make-secd
                                                 op-stack
                                                 fun-stack
                                                 env
                                                 (rest code)
                                                 dump
                                                 heap-inst-new)))
                                            (make-secd
                                             op-stack
                                             fun-stack
                                             env
                                             (rest code)
                                             dump
                                             heap-inst)
                                            ))))

                                   ((heap-get-at? (first code))                                
                                    (let* (
                                           [identifier (stack-element-value (op-stack 'pop!))]
                                           [act-value (lookup-heap-stor  heap-inst  identifier)])
                                      (begin
                                        (debug-snap-heap heap-inst "print heap in get")
                                        (op-stack 'push! (new-stack-element 'app act-value))
                                        (make-secd
                                         op-stack
                                         fun-stack
                                         env
                                         (rest code)
                                         dump
                                         heap-inst)
                                        )
                                                
                                      ))
                                     
                                   ((where? (first code))
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
                                                        dump
                                                        heap-inst)])
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
                                                      heap-inst)
                                          ) ) ))
                                     
                                   

                                   ((prim? (first code))                    
                                    (begin
                                      (print-stack-env-code op-stack fun-stack env (rest code) "prim? enter op stack--> ")                           
                                      (write-object-nl (list "OP - CODE:"(prim-operator (first code))))
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
                                                        dump
                                                        heap-inst)])
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
                                         heap-inst
                                         ))))                 
                                  
                               

                                   ((app-fun? (first code))                             
                                    (process-fun-app (first code) state
                                                     )
                                    )
                             
                                   ((ap? (first code))
                                    (begin
                                      (debug-snap-stack op-stack "Operating Stack")
                                      (debug-snap-stack fun-stack "Function Stack")
                                      (let ([parameter-binding (stack-element-value (op-stack 'pop!))]                                   
                                            [the-closure (fun-stack  'pop!)])
                                      
                                    
                              
                                        (begin
                                          (print-stack-env-code op-stack fun-stack env code  "debug the ap?")
                                          (write-object-nl "Enter application ->")
                                 
                              
                                    
                                 
                                    
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
                                                  (fresh-stack 'push! (op-stack 'peekit)) ;;;peekit before that
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
                                                           heap-inst)
                                              ) ) ))))
                   
                                   ((tailap? (first code)) ;; nach stack und environment sehen
                                    (let ([closure (fun-stack 'pop!)]
                                          [fresh-stack (make-stack (list))]) ;; (define closure (first (rest stack)))
                                      (begin                                  
                                        (print-stack-env-code op-stack fun-stack env code  "debug the tailap?")
                                        ( cond
                                           ((> (op-stack 'size) 0)
                                            (fresh-stack 'push! (op-stack 'peekit)) ;;;peekit before that
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
                                                   dump
                                                   heap-inst))))              
                                   (else
                                    (leave-context op-stack fun-stack dump heap-inst)
                                    )))
                               (leave-context op-stack fun-stack dump heap-inst)))))

(define leave-context
  (lambda (op-stack fun-stack dump heap-inst)
    (let* ([ frame (first dump) ]       
           [ret-stack (frame-stack frame)]
           ;;  [ret-stack (op-stack 'add-all! ret-stack)]
           )
      (begin
        (write-object-nl "=============================== Begin fun shutdown =====================")
        (debug-snap-stack op-stack "Actual Stack")
        ;; (debug-snap-env env "Actual Environment")
        (write-object-nl "=============================== End fun shutdown =====================")
                                  
        -(write-object-nl "=============================== FINISH =====================")
        (write-object-nl "========THE FRAME FROM DUMP=====================")
        (debug-snap-frame frame "code is empty get from dump")
        (write-object-nl "========END THE FRAME FROM DUMP=====================")
        (write-object-nl "=============================== FINISH =====================")
                                  
        (begin
                                      
                               
          (cond
            ((> (op-stack 'size)  0)
             (ret-stack 'push! (op-stack 'peekit) ;; herre was a 'peekit
                        ))
            (else 'do-nothing
                  ))
                                
          (make-secd
           (remove-params-from-stack ret-stack (make-stack (list)))
           ;;ret-stack ;; ATTENT
           (frame-fun-stack frame)
           (frame-environment frame)
           (frame-code frame)
           (rest dump)
           heap-inst)
          ))
      )))

(define remove-params-from-stack
  (lambda (old-stack fresh-stack)
  
   
    (if (>  (old-stack 'size)0)
        (let
            ([act-value (old-stack 'pop!)]
             )
          (begin
            (if (equal? 'app (stack-element-type act-value))
                (fresh-stack 'push! act-value)
                'nothing )
            ( cond
               ((> (old-stack 'size) 0)
                (remove-params-from-stack old-stack fresh-stack)
                )
               (else
                (begin
                  (fresh-stack 'reverse!)
                  fresh-stack
                  ))
               )
      
            ))
        (make-stack (list)
                    ))))
(define def-closure
  (lambda (env dump op-stack  fun-stack fun-ref)
    (let* ( [the-abst-code  (lookup-environment
                             env
                             dump
                             fun-ref)])
      (if (or (empty? the-abst-code) (not (abst? the-abst-code)))
          (fun-stack 'pop!)
          (begin
            (op-stack 'pop!)
            (make-closure
             (abst-variable (first  the-abst-code))
             (abst-code (first  the-abst-code))                                                              
             env)                           
            )))))


(define process-fun-app
  (lambda (app-fun-rec secd-state)
    (define code (secd-code secd-state))
    (define env (secd-environment  secd-state))
    (define op-stack (secd-stack secd-state))
    (define fun-stack (secd-fun-stack secd-state))
    (define dump (secd-dump secd-state))
    (define heap-inst (secd-heap secd-state))
    (begin
      (write-object-nl  "Enter app fun ->")
      (debug-snap-env env "start processing")
      (debug-snap-stack op-stack "start processing OP_STACK")
      (debug-snap-stack fun-stack "start processing FUN_STACK")
       
      (let* (                                   
             [identifier (stack-element-value (op-stack 'pop!)) ]
             [abstract-rec  (lookup-environment
                             env
                             dump
                             identifier)]
             [parameter-binding (stack-element-value (op-stack 'pop!))]
             [the-closure (make-closure (abst-variable (first abstract-rec))
                                        (abst-code (first abstract-rec))
                                        env)])
                                      
                                    
                              
        (begin
          (print-stack-env-code op-stack fun-stack env code  "debug the ap?")
          (write-object-nl "Enter application ->")
                                 
                              
                                    
                                 
                                    
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
                )
           
            (make-secd   op-stack
                         (make-stack  (list))         
                         extended-env                                   
                         (closure-code the-closure)
                         (cons
                          ;;  (first stack))
                          (make-frame op-stack fun-stack env (rest code))
                          dump)
                         heap-inst)
            ) ) ))))
                   
  

                     
                   
                     
     
    

(define do-is
  (lambda (is-cond secd-state)
    (define code (secd-code secd-state))
    (define env (secd-environment  secd-state))
    (define op-stack (secd-stack secd-state))
    (define fun-stack (secd-fun-stack secd-state))
    (define dump (secd-dump secd-state))
    (define heap-inst (secd-heap secd-state))
    (let*  (

            [fresh-stack (make-stack (list))]
            [dummy-w (write-object-nl (list "the case object" is-cond))]
            [dummy    ( cond
                         ((> (op-stack 'size) 0)
                          (fresh-stack 'push! (op-stack 'peekit))
                          )
                         (else (make-stack (list)))
                         )]
            [cond-code  (single-cond-what (first code))]
            [cond-secd (make-secd
                        fresh-stack
                        fun-stack
                        env
                        cond-code
                        dump
                        heap-inst)])
      (begin
                                  
        (let* ([res-secd  (secd-exec-prim cond-secd)]
               [res-op-stack (secd-stack res-secd)]
               [res-fun-stack (secd-fun-stack res-secd)]
               [res-env (secd-environment res-secd)]
               [res-dump (secd-dump res-secd)]                                  
               [cond-result
                (stack-element-value (res-op-stack 'pop!))]
               [the-code  (if cond-result
                              (single-cond-code (first code))
                              (rest code))])
          (begin
             (write-object-nl (list "Code executed: -> " the-code))
          (make-secd  op-stack ;; op-stack
                      fun-stack
                      env                                                                               
                      the-code                   
                      dump
                      heap-inst)))))))

(define closure-apply
  (lambda (secd-rec new-code)
    (let* ([fresh-stack (make-stack (list))]            
           [the-closure  (make-closure
                          'NONE
                          new-code                                                             
                          (secd-environment secd-rec)) ]
           [op-stack (secd-stack secd-rec)])
      (begin
        ( cond
           ((> (op-stack 'size) 0)
            (fresh-stack 'push! (op-stack 'peekit))) ;;;peekit before that
                                            
           (else  list))
                                     
        (make-secd
         op-stack
         (make-stack (list))
         (secd-environment secd-rec)                                                                                                        
         (closure-code the-closure)
         (cons
          (make-frame op-stack
                      (secd-fun-stack secd-rec)
                      (secd-environment secd-rec) 
                      (rest
                       (secd-code secd-rec) ))
          (secd-dump secd-rec) )
         (secd-heap secd-rec) 
         )))))
                   

(define eval-secd (lambda (ast)
                    (let* ([fresh-stack (lambda ()
                                          (make-stack (list)))]
                           [secd-mach (make-secd  (fresh-stack)
                                                  (fresh-stack)
                                                  (ast-env ast)
                                                  (ast-code ast)
                                                  (ast-dump ast)
                                                  (make-heap (list)))]
                           [new-frame (make-frame (fresh-stack) (fresh-stack) (ast-env ast)  empty)]
                           [dump (append (list new-frame) (ast-dump ast))]
                           [result
                            (process (make-ast (fresh-stack) (ast-code ast) empty (ast-env ast) dump))])
                    
                      (stack-element-value ((secd-stack result) 'pop!)
                                           ))))

;;(check-expect (eval-secd (compile-secd '((lambda (x) (mul 5 x)) 2))) 10)
;; this tiny scheme code is the level for the next step
#;(check-expect  (eval-secd  (compile-secd '((define test-west
                                               (lambda (x)                                             
                                                 (mul x 9)))
                                             (define higher (lambda (u)
                                                              (add 5 (app-fun test-west u))
                                                              ))
                                             (app-fun higher 7))))  68)

#;(check-expect  (eval-secd   (compile-secd'((define test-west
                                               (lambda (x)                                             
                                                 (mul x 9) ))
                                             (define higher (lambda (u)
                                                              (add 5 (app-fun test-west u))
                                                              ))
                                             (app-fun higher 10)
                                             (app-fun higher 7)
                                             ))) 68)

(define the-test-case-code '((define test-west
                               (lambda (x)
                                 (lambda (y)
                                   (mul x y))))
                             (define higher (lambda (u)
                                              (lambda (t)
                                                (add t ((app-fun test-west u) u))
                                                )))
                             ((app-fun higher 10) 12)))

;;(check-expect  (compile-secd the-test-case-code) 65)
#;(check-expect  (eval-secd  (compile-secd the-test-case-code)) 112)

#;(check-expect (eval-secd (compile-secd'((define test-west
                                            (lambda (x)
                                 
                                              (mul x 18)))
                                          (define higher (lambda (u)
                                                           (lambda ((x-x-x))
                                                             (cond-branch (== u 17)
                                                                          (add 5 (app-fun test-west u))
                                                                          (add 5 (app-fun test-west 12)))
                                                             )))
                                          ((app-fun higher 6) 0))))  221)

#;(check-expect (eval-secd (compile-secd'((define test-west
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
                                          (define higher (lambda (x)
                                             
                                                           (cond-branch (< x 11)
                                                                        (mul 5 (add 7 x))
                                                                        (add 5 (app-fun higher 10))
                                                                        )))
                                          (app-fun higher 15))))  90)
;(check-expect (eval-secd(compile-secd '(((lambda (x) (lambda (y) (mul y  (add x y)))) 1) 2))) 6)   
;;(check-expect (eval-secd(compile-secd '(((lambda (x) (lambda (y) (div 120 (mul y  (add x y) ) )) 1) 2)))) 20)



;; Ultimativer Test

#;(check-expect (eval-secd (compile-secd
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
                                                 (cond-branch (< x 11)
                                                              (mul 5 (add 7 x))
                                                              (cond-branch (> x 20)
                                                                           (add 5 (mul 9 x))
                                                                           (add x x))
                                                              )))
                                (app-fun higher 10)
                                (app-fun higher 19)
                                (app-fun higher 22)
                                ) )) 203)

#;(check-expect (eval-secd
                 (compile-secd
                  '((define allocator
                      (lambda (x)
                        (add (heap-alloc g 8)
                             (sub (mul x (heap-set-at! g 16))
                                  (heap-get-at g))
                             )))
                    (define higher (lambda (x)                                             
                                     (cond-branch (< x 11)
                                                  (mul 8 7)
                                                  (add (app-fun allocator 100) (app-fun higher 10))
                                                  )))
                    (app-fun higher 12))))  1648)

(check-expect  (eval-secd (compile-secd
                             '((define allocator
                                 (lambda (x)
                                   (add (heap-alloc g 8)
                                        (sub (mul x (heap-set-at! g 16))
                                             (heap-get-at g))
                                        )))
                               (define higher (lambda (x)
                                               
                                                 (where-cond  
                                                  (is? (== x 40)
                                                       (add 3 4))
                                                  (is? (== x 80)
                                                       (sub x  10))
                                                  (is? (== x 11)
                                                       (mul 8 7))
                                                  (is? (== x 12)
                                                       (add (apply-fun allocator 100) 10)
                                                       ))
                                               
                                                ))
                               (apply-fun higher 12)))) 1602)


#;(check-expect  (eval-secd
                (compile-secd
                 '((define allocator
                     (lambda (x)
                       (lambda (y)
                         (lambda (y)
                           (add (heap-alloc g 8)
                                (sub (mul x (heap-set-at! g 16))
                                     (heap-get-at g))
                                )))))
                   (apply-fun allocator 7 8 9)))) 8)

#;(check-expect  (eval-secd
                (compile-secd
                 '((define allocator
                     (lambda (x y z)                      
                       (sub (add x y) z)))                 
                   (apply-fun allocator 7 8 9)))) 6)

(check-expect  (eval-secd (compile-secd
                           '((define allocator
                               (lambda (x)
                                 (add (heap-alloc g 8)
                                      (sub (mul x (heap-set-at! g 16)) ;;check this again
                                           (heap-get-at g))
                                      )))
                             (define higher (lambda (x)                          
                                              (where-cond  
                                               (is? (== x 40)
                                                    (add 3 4))
                                               (is? (== x 80)
                                                    (sub x  10))
                                               (is? (== x 11)
                                                    (add (apply-fun allocator 9) (mul 8 7))
                                               ))
                                
                                              ))
                             (apply-fun higher 11)))) 192)

#;(check-expect  (eval-secd (compile-secd
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
                                          (add 3 4)
                                          (break))
                                     (is? (== x 80)
                                          (sub x (apply-fun higher 10))
                                          (break))
                                     (is? (< x 11)
                                          (mul 8 7)
                                          (break))
                                     (is? (> x 12)
                                          (add (apply-fun allocator 100) (apply-fun higher 10))
                                          (break)
                                          ))
                                    (cond-branch (> x 1100)
                                                 (mul 3 90)
                                                 (add (apply-fun allocator 200) (apply-fun higher 110))
                                                 ))
                                   ))
                  (apply-fun higher 10)))) 185)
