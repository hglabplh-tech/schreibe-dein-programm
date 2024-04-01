#lang deinprogramm/sdp/advanced
(require 
  "vmdefs.rkt"
  "vmcore.rkt"
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
                         [state (make-secd op-stack env code dump)])
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
                                    (op-stack 'print-stack)
                                    (write-string "push closure") 
                                    (op-stack 'push! the-closure)
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
                                                ((op-operation (first code)) op-stack val)       ;; NEW e have the proceedure
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
                                               ((op-operation (first code)) op-stack bound-value)
                                               ;;(op-stack 'push!  bound-value))
                                               )
                                        
                                             ;; TODO: handle stack in the right way
                              
                                             ))) )
                                   
                                  (make-secd
                                   op-stack
                                   env
                                   (rest code)
                                   dump)
                                  
                                  )))
                             
                             ((base? (first code))
                              (begin
                        
                                (op-stack 'push! (first code))
                                (make-secd
                                 op-stack
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
                                (op-stack 'push! 
                                          (apply-primitive (prim-operator (first code))
                                                           (list (temp-stack 'pop!)                             
                                                                 (temp-stack 'pop!))))

                                (let ([secd-ret  (make-secd
                                 op-stack
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
                                       extended-env
                                       (rest code)
                                       dump)
                                      )))
                                  
                                       
                                  
                                  
                               

                             ((app-fun? (first code)) ;; correct this by retrieve closure from stack
                              (begin
                                    (debug-to-print-secd state "cal in app fun")
                                (write-newline)
                                (write-string "try to get from env: ")
                                (debug-to-print-app-fun (first code) "app-fun case")
                                (write-string (symbol->string (app-fun-variable (first code))))
                                (write-newline)
                                (let* ([the-abst-code  (lookup-environment
                                                       env
                                                        dump
                                                        (app-fun-variable (first code)))]
                                       [the-closure  (make-closure
                                                      (abst-variable (first  the-abst-code))
                                                       (abst-code (first  the-abst-code))                                                                
                                                      env)]
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
                                    (let* ([parameter-binding  (op-stack 'pop!)]
                                           [parm-name (if (abst? (first the-abst-code))
                                                          (abst-variable (first the-abst-code))
                                                          'unknown)]
                                           [extended-env  (extend-environment
                                                           (closure-environment the-closure)
                                                           parm-name                                                          
                                                           parameter-binding)])
                                      (begin
                                           
                                        (temp-stack 'clear!)
                                        (temp-stack 'push!  parameter-binding)
                                        (write-object-nl "temp stack content")
                                        (temp-stack 'print-stack)
                                        (op-stack 'print-stack)
                                        (make-secd
                                        op-stack                                            
                                         extended-env                                                                                                                  
                                         (closure-code the-closure)
                                         (cons
                                          (make-frame op-stack extended-env (rest code))
                                          dump)
                                         )))))))
                             
                             ((ap? (first code))
                              (let ([parameter-binding (op-stack 'pop!)]
                                    [the-closure
                                     (if (closure?
                                          (op-stack 'peekit))
                                         (op-stack 'peekit)
                                         (op-stack 'pop!))]
                                    )
                              
                                (begin
                                      (debug-to-print-secd state "debug the ap?")
                                  (write-object-nl "Enter application ->")
                                  (op-stack 'print-stack)
                              
                                    
                                 
                                    
                                  (op-stack 'print-stack)

                         
                                  (write-newline )                              
                                  (write-string "Parameter Binding: ")
                                  (write-string (number->string parameter-binding))
                                  (write-newline)

                                  
                                  (make-secd   (make-stack  (list))         
                                             (extend-environment
                                              (closure-environment the-closure)
                                              (closure-variable the-closure)
                                              parameter-binding)                                          
                                             (closure-code the-closure)
                                             (cons
                                              ;;  (first stack))
                                              (make-frame op-stack env (rest code))
                                              dump)
                                             ) ) ))
                   
                             ((tailap? (first code))
                              (let ([closure (op-stack 'pop!)]) ;; (define closure (first (rest stack)))
                                (begin
                                      (debug-to-print-secd state "debug the tailap?")
                                (make-secd   op-stack
                                           (extend-environment
                                            (closure-environment closure)
                                            (closure-variable closure)
                                            (op-stack 'pop!))    
                                           (closure-code closure)
                                           dump))))

                                 ((stop? (first code))
                              (let ([ frame (first dump)])
                                (begin
                                  (write-object-nl "=============================== FINISH =====================")
                                  (write-object-nl "========THE FRAME FROM DUMP=====================")
                                  (debug-snap-frame frame "code is empty get from dump")
                                  (write-object-nl "========END THE FRAME FROM DUMP=====================")
                                  (write-object-nl "=============================== FINISH =====================")
                         
                                  (op-stack 'add-all!  (frame-stack frame))
                                  (make-secd
                                   op-stack
                                   (frame-environment frame)
                                   (frame-code frame)
                                   (rest dump))
                                  )))
                                  ;;      ((empty? code)
                                 (else
                              (let ([ frame (first dump)])
                                (begin
                                  (write-object-nl "=============================== FINISH =====================")
                                  (write-object-nl "========THE FRAME FROM DUMP=====================")
                                  (debug-snap-frame frame "code is empty get from dump")
                                  (write-object-nl "========END THE FRAME FROM DUMP=====================")
                                  (write-object-nl "=============================== FINISH =====================")
                         
                                  (op-stack 'add-all!  (frame-stack frame))
                                  (make-secd
                                   op-stack
                                   (frame-environment frame)
                                   (frame-code frame)
                                   (rest dump))
                                  ))
                              ))              
      (let ([ frame (first dump)])
                                (begin
                                  (write-object-nl "=============================== FINISH =====================")
                                  (write-object-nl "========THE FRAME FROM DUMP=====================")
                                  (debug-snap-frame frame "code is empty get from dump")
                                  (write-object-nl "========END THE FRAME FROM DUMP=====================")
                                  (write-object-nl "=============================== FINISH =====================")
                         
                                  (op-stack 'add-all!  (frame-stack frame))
                                  (make-secd
                                   op-stack
                                   (frame-environment frame)
                                   (frame-code frame)
                                   (rest dump))
                                  ))
                         
                            
                             )
                           
                           )))          
                   

(define eval-secd (lambda (ast)
                    (let* ([fresh-stack (lambda ()
                                          (make-stack (list)))]
                           [secd-mach (make-secd  (fresh-stack) (ast-env ast) (ast-code ast) (ast-dump ast))]
                           [new-frame (make-frame (fresh-stack) (ast-env ast)  empty)]
                           [dump (append (list new-frame) (ast-dump ast))]
                           [result
                            (process (make-ast (fresh-stack) (ast-code ast) empty (ast-env ast) dump))])
                    
                      ((secd-stack result) 'pop!)
                      )))

;;(check-expect (eval-secd (compile-secd '((lambda (x) (mul 5 x)) 2))) 10)
;; this tiny scheme code is the level for the next step
#;(check-expect  (eval-secd  (compile-secd'((define test-west
                                            (lambda (x)                                             
                                              (mul x 9)))
                                          (define higher (lambda (u)
                                                           (add 5 (app-fun test-west u))
                                                           ))
                                          (app-fun higher 10)))) 42) ;
(check-expect  (eval-secd   (compile-secd'((define test-west
                                            (lambda (x)                                             
                                              (mul x 9) ))
                                          (define higher (lambda (u)
                                                             (add 5 (app-fun test-west u))
                                                             ))
                                          (app-fun higher 10)
                                          (app-fun higher 7)
                                          ))) 42) ;
#;(check-expect  (eval-secd  (compile-secd'((define test-west
                                              (lambda (x)
                                                (lambda (y)
                                                  (mul x y))))
                                            (define higher (lambda (u)
                                                             (lambda ()
                                                               (add 5 ((app-fun test-west u) 6))
                                                               )))
                                            (app-fun higher 10)))) 42) ; wisdom
;(check-expect (eval-secd(compile-secd '(((lambda (x) (lambda (y) (mul y  (add x y)))) 1) 2))) 6)   
;;(check-expect (eval-secd(compile-secd '(((lambda (x) (lambda (y) (div 120 (mul y  (add x y) ) )) 1) 2)))) 20)
