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
                      (debug-to-print-secd state "debug initialize processing")
                      (secd-step* state)))))


(define secd-step*
  (lambda (state)
    (if (and (empty? (secd-code state))
             (empty? (secd-dump state)))
        state
        (secd-step* (really-process state)) ) ))


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
                         ;;  (debug-to-print-secd state "debug enter processing")
                           (cond                         
                             ((abst? (first code))
                              (begin
                                    (debug-to-print-secd state "call in absttraction")
                                (let ([the-closure  (make-closure
                                                     (abst-variable (first code))
                                                     (abst-code (first code))                                                                           
                                                     env)])
                                  (begin
                                    (write-string "there is NO closure ON stack.....")
                                
                                    (write-string "push closure") 
                                    (fun-stack 'push! the-closure)
                                    (fun-stack 'print-stack)
                                    (write-object-nl "temp stack content")
                                    (temp-stack 'print-stack)                                  
                                    (cond
                                      ((equal? (temp-stack 'size) 1)
                                       (begin
                                         (write-object-nl "push the value")
                                         
                                         (op-stack 'push! (temp-stack 'pop!)))))
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
                                             (begin
                                               (write-string (number->string bound-value))
                                               ((op-operation (first code))  op-stack  (new-stack-element 'app
                                                                                              bound-value))
                                               ;;(op-stack 'push!  bound-value))
                                               )
                                        
                                             ;; TODO: handle stack in the right way
                              
                                             ))) )
                                   
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
                             
                           
                                     
        

                             ((prim? (first code))                    
                              (begin
                              
                                (write-newline)
                                (write-string "enter calculation")
                                (write-newline)
                                (temp-stack 'push! (op-stack 'pop!))
                                (temp-stack 'push! (op-stack 'pop!))
                                (write-newline)
                                (write-string (symbol->string  (prim-operator (first code))))
                                (write-newline)
                                                     
                                ;;(op-stack 'push! 
                                ;((pcode->fun  (prim-operator (first code)))
                                (op-stack 'push! (new-stack-element 'app
                                          (apply-primitive (prim-operator (first code))
                                                           (list (stack-element-value  (temp-stack 'pop!))                         
                                                                 (stack-element-value  (temp-stack 'pop!))))))

                                (let ([secd-ret  (make-secd
                                 op-stack
                                 fun-stack
                                 env
                                 (rest code)
                                 dump)])
                                 (begin
                                    (debug-to-print-secd secd-ret "state given by prim? --> ")
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
                                       [the-value (if (and (cons? the-value) (abst? (first the-value)))
                                                      (append the-value (list (make-stop)))
                                                      the-value
                                                      )]
                                       [extended-env (extend-environment
                                                      env
                                                      the-binding                                                          
                                                      the-value)])
                               
                                      (make-secd
                                       op-stack
                                       fun-stack
                                       extended-env
                                       (rest code)
                                       dump)
                                      )))
                                  
                                       
                                  
                                  
                               

                             ((app-fun? (first code))                             
                                (process-fun-app  state (first code)
                                )
                                )
                             
                             ((ap? (first code))
                              (let ([parameter-binding (stack-element-value (op-stack 'pop!))]
                                    [the-closure (fun-stack  'pop!)])                            
                                    
                              
                                (begin
                                      (debug-to-print-secd state "debug the ap?")
                                  (write-object-nl "Enter application ->")
                                  (op-stack 'print-stack)
                              
                                    
                                 
                                    
                                  (op-stack 'print-stack)                        
                                  (write-newline )                              
                                  (write-string "Parameter Binding: ")
                                  (write-string (number->string parameter-binding))
                                  (write-newline)

                                  
                                  (make-secd   op-stack
                                               (make-stack  (list))         
                                             (extend-environment
                                              (closure-environment the-closure)
                                              (closure-variable the-closure)
                                              parameter-binding)                                          
                                             (closure-code the-closure)
                                             (cons
                                              ;;  (first stack))
                                              (make-frame op-stack fun-stack env (rest code))
                                              dump)
                                             ) ) ))
                   
                             ((tailap? (first code))
                              (let ([closure (fun-stack 'pop!)]) ;; (define closure (first (rest stack)))
                                (begin
                                      (debug-to-print-secd state "debug the tailap?")
                                (make-secd   op-stack
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

                                  (cond ((and ( >=( ret-stack 'size) 2) (equal? (stack-element-type  (ret-stack 'peekit)
                                      ) 'param))
                                      (ret-stack 'swap-last!)
                                      )
                                        (else 'nothing)
                                        )
                                  (ret-stack 'push!    (op-stack 'pop!))
                                  (make-secd
                                   ret-stack
                                   fun-stack
                                   (frame-environment frame)
                                   (frame-code frame)
                                   (rest dump))
                                  ))
    ))

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
                                                           parameter-binding)])
                                      (begin
                                           
                                        (temp-stack 'clear!)
                                        (temp-stack 'push!  (new-stack-element 'param parameter-binding))
                                        (write-object-nl "temp stack content")
                                        (temp-stack 'print-stack)
                                        (op-stack 'print-stack)
                                        (make-secd
                                        op-stack
                                        fun-stack
                                         extended-env                                                                                                                  
                                         (closure-code the-closure)
                                         (cons
                                          (make-frame op-stack fun-stack extended-env (rest code))
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
(check-expect  (eval-secd  (compile-secd'((define test-west
                                            (lambda (x)                                             
                                              (mul x 9)))
                                          (define higher (lambda (u)
                                                           (add 5 (app-fun test-west u))
                                                           ))
                                          (app-fun higher 10)))) 95)

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
                                                             (lambda ()
                                                               (add 5 ((app-fun test-west u) 6))
                                                               )))
                                            ((app-fun higher 10))))) 65) ; wisdom
;(check-expect (eval-secd(compile-secd '(((lambda (x) (lambda (y) (mul y  (add x y)))) 1) 2))) 6)   
;;(check-expect (eval-secd(compile-secd '(((lambda (x) (lambda (y) (div 120 (mul y  (add x y) ) )) 1) 2)))) 20)
