#lang deinprogramm/sdp/advanced
(require 
  "vmdefs.rkt"
  "vmcore.rkt"
  "stack.rkt"
  "operations.rkt")


(define temp-stack (make-stack (list)))

(define process (lambda (ast)
                  (let* ([op-stack (ast-stack ast)]
                         [code (ast-code ast)]
                         [env (ast-env ast )]
                         [dump (ast-dump ast)]
                         [act-frame (first (ast-dump ast))]
                         [secd-m (make-secd op-stack env code dump)])                  
                    (really-process secd-m))))

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
                           (cond
                             ((empty? code)
                              (empty-proc op-stack env code dump "  ((empty? code)")
                              )
                             
                             ((abst? (first code))
                           
                               
                              (let ([peek-result (op-stack 'peekit)])
                                (if (closure? peek-result)
                                    (begin
                                      (write-string "there is a closure on stack.....")
                                      (really-process (make-secd
                                                       op-stack
                                                       env
                                                       (call-abstract-pop! (closure-code peek-result)
                                                                           op-stack)
                                                       ;;(rest code)
                                                       dump)))
                                    (begin
                                      (let ([the-closure  (make-closure (abst-variable (first code))
                                                               
                                                                        (abst-code (first code)
                                                                                   )
                                                                        env)])
                                        (begin
                                          (write-string "there is NO closure ON stack.....")
                                          (op-stack 'print-stack)
                                          (write-string "push closure")
                                          (op-stack 'push! the-closure)
                                          (op-stack 'print-stack)
                                          (really-process (make-secd
                                                           op-stack
                                                           env
                                                           ;;(closure-code the-closure)
                                                           (rest code)
                                                           dump)))))
                                          
                                    )))
                                  
                        
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
                                                ((op-operation (first code)) op-stack val);; NEW e have the proceedure
                                                ;; here it is a 'push!
                                                ) )
                                        ((symbol? val) ;; do the right order of income
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
                                  ( really-process
                                    (make-secd
                                     op-stack
                                     env
                                     (rest code)
                                     dump))
                                  
                                  )))
                             
                             ((base? (first code))
                              (begin
                        
                                (op-stack 'push! (first code))
                                ( really-process
                                  (make-secd
                                   op-stack
                                   env
                                   (rest code)
                                   dump))
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

                                ( really-process
                                  (make-secd
                                   op-stack
                                   env
                                   (rest code)
                                   dump))
                               
                               
                                ))

                             ((define-def? (first code))
                              (begin
                                (write-newline)
                                (write-string "try to put to env: ")
                                (write-string (symbol->string (define-def-bind (first code))))
                                (write-newline)                               
                                (let* ([the-binding (define-def-bind (first code))]
                                       [the-value (define-def-value (first code))]                                               
                                       [the-closure  (make-closure (abst-variable (first the-value))
                                                                   (abst-code (first the-value))
                                                                   env)]                                           
                                       
                                       [extended-env (extend-environment
                                                      env
                                                      the-binding                                                          
                                                      the-closure)])
                                  (begin
                                    (write-newline)
                                    (write-string "got it now")
                                    (write-newline)                              
                                    (write-string "do recursive call in  def")                                 
                                  
                                    (really-process (make-secd
                                                     op-stack
                                                     extended-env
                                                     (rest code)
                                                     dump))
                                    )))) 
                                  
                                       
                                  
                                  
                               

                             ((app-fun? (first code))
                              (begin
                                (write-newline)
                                (write-string "try to get from env: ")
                                (write-string (symbol->string (app-fun-variable (first code))))
                                (write-newline)
                                (let ([the-closure (lookup-environment env
                                                                        dump
                                                                        (app-fun-variable (first code)))])
                              
                                (begin
                                  (write-newline)
                                  (write-string "after lookup:  ")
                                  (if (empty? the-closure)
                                      (write-string "no binding found") 
                                      (begin           
                                     
                                                                   
                                        (write-newline)
                                        (write-string "Parameter list app-fun: ")
                                        (if (number? (first (app-fun-params (first code))))
                                            (write-string (number->string (first (app-fun-params (first code) ))
                                                                          ))
                                            (write-string (symbol->string (first (app-fun-params (first code) ))
                                                                          )))
                                        (write-newline)
                                        (let ((parameter-binding  (if (symbol? (first (app-fun-params (first code))))
                                                                      (lookup-environment env
                                                                                          dump
                                                                                          (first (app-fun-params (first code))))
                                                                      (first (app-fun-params (first code)))))
                                              )
                                          (begin
                                            (write-string "push closure app-fun: ")
                                  
                                            (op-stack 'push! the-closure)
                                  
                                            (op-stack 'print-stack)
                                            (really-process (make-secd
                                                             op-stack
                                                             (extend-environment
                                                              (closure-environment the-closure)
                                                              (closure-variable the-closure)
                                                              parameter-binding)                                                           
                                                             (closure-code the-closure)
                                                             (cons
                                                              ;;  (first stack))
                                                              (make-frame op-stack env (rest code))
                                                              dump)
                                                             ) )
                                   
                                           
                               
                                            ))))))))

                             ((return-inst? (first code))
                                   (op-stack 'push! ( really-process
                                  (make-secd
                                   op-stack
                                   env
                                  (first (return-inst-thing (first code)))
                                   dump))))
                             
                             ((ap? (first code))
                              (let ([parameter-binding (op-stack 'pop!)]
                                    [the-closure
                                     (if (closure?
                                          (op-stack 'peekit))
                                         (op-stack 'peekit)
                                         (op-stack 'pop!))]
                                    )
                              
                                (begin
                                  (op-stack 'print-stack)
                              
                                    
                                 
                                    
                                  (op-stack 'print-stack)

                         
                                  (write-newline )                              
                                  (write-string "Parameter Binding: ")
                                  (write-string (number->string parameter-binding))
                                  (write-newline)

                                  
                                  (really-process (make-secd op-stack
                                                             (extend-environment
                                                              (closure-environment the-closure)
                                                              (closure-variable the-closure)
                                                              parameter-binding)                                          
                                                             (closure-code the-closure)
                                                             (cons
                                                              ;;  (first stack))
                                                              (make-frame op-stack env (rest code))
                                                              dump)
                                                             ) ) ) ))
                   
                             ((tailap? (first code))
                              (let ([closure (op-stack 'pop!)]) ;; (define closure (first (rest stack)))
          
                                (really-process  (make-secd op-stack
                                                            (extend-environment
                                                             (closure-environment closure)
                                                             (closure-variable closure)
                                                             (op-stack 'pop!))    
                                                            (closure-code closure)
                                                            dump))))
   
                         
                             ((empty? (rest code))
                              (empty-proc op-stack env code dump "((empty? (rest code))")
                              )))))

(define empty-proc (lambda (op-stack env code dump msg)
                     (let ([ frame (first dump)])
                       (begin
                         (op-stack 'add-all!  (frame-stack frame))
                         (let ((machine-state 
                                (make-secd
                                 op-stack
                                 (frame-environment frame)
                                 (rest (frame-code frame))
                                 (rest dump))
                                ))
                           (begin
                             (write-newline)
                             (write-string "process recursive-call: ")
                             (write-string msg)
                             (write-newline)
                             ))))))
                   

(define eval-secd (lambda (ast)
                    (let* ([fresh-stack (lambda ()
                                          (make-stack (list)))]
                           [secd-mach (make-secd  (fresh-stack) (ast-env ast) (ast-code ast) (ast-dump ast))]
                           [new-frame (make-frame (fresh-stack) (ast-env ast) (ast-code ast) )]
                           [dump (append (list new-frame) (ast-dump ast))]
                           [result
                            (process (make-ast (fresh-stack) (ast-code ast) empty (ast-env ast) dump))])
                    
                      ((secd-stack result) 'pop!)
                      )))

;;(check-expect (eval-secd (compile-secd '((lambda (x) (mul 5 x)) 2))) 10)
;; this tiny scheme code is the level for the next step
(check-expect  (eval-secd  (compile-secd'((define test-west
                                           (lambda (x)
                                             (lambda (y)
                                             (return (mul x y)))))
                                         (define higher (lambda (y)
                                                          (lambda ()
                                                          (return (add 5 ((app-fun test-west y) 6))
                                                            ))))
                                         (return app-fun higher 10)))) 42) ; wisdom
;(check-expect (eval-secd(compile-secd '(((lambda (x) (lambda (y) (mul y  (add x y)))) 1) 2))) 6)   
;;(check-expect (eval-secd(compile-secd '(((lambda (x) (lambda (y) (div 120 (mul y  (add x y) ) )) 1) 2)))) 20)
