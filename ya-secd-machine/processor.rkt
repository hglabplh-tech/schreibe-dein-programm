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

(define really-process (lambda (state)
                         (define op-stack (secd-stack state))
                         (define env (secd-environment state))
                         (define code (secd-code state))
                         (define dump (secd-dump state))
                         (begin
                           (cond                            
                             ((abst? (first code))
                              (let ([the-closure  (make-closure (abst-variable (first code))
                                                                (abst-code (first code))
                                                                env)])
                                (begin
                                  (write-string "push closure")
                                  (op-stack 'push! the-closure)
                                  (make-secd
                                   op-stack
                                   env
                                   (rest code)
                                   dump))))
                        
                             ((op?  (first code))                     
                              (let ([val (first (op-params (first code)))])
                                (cond ((base? val)
                                       (begin (write-string "get constant")
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
                                         (write-string "get var")
                                         (write-newline)
                                         (write-string "push variable par: ")
                                         (write-string (symbol->string val))
                                         (write-newline)
                                         (write-string  (symbol->string val))
                                         (let ([bound-value  (lookup-environment
                                                            env
                                                            val)])
                                           (begin
                                           (write-string (number->string bound-value))
                                           ((op-operation (first code)) op-stack bound-value)
                                            ;;(op-stack 'push!  bound-value))
                                           )
                                        
                                  ;; TODO: handle stack in the right way
                              
                                         ))) )
                                  
                              ))
                             ((base? (first code))
                              (begin
                        
                                (op-stack 'push! (first code))
                                (make-secd op-stack
                                           env
                                           (rest code)
                                           dump)))
                             
                             ((symbol? (first code))
                              (begin
                                (op-stack 'push! (lookup-environment env (first code)))))
        

                             ((prim? (first code))                    
                              (begin
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

                                (op-stack   'print-stack)
                                 (make-secd
                                   op-stack
                                   env
                                   (rest code)
                                   dump)
                               
                               
                                ))
                    
                     
                             ((ap? (first code))
                              (begin
                                (op-stack 'print-stack)
                                (define parameter-binding (op-stack 'pop!))
                                 (op-stack 'print-stack)
                                (define the-closure (op-stack 'pop!))  ;;(define closure (first (rest stack)))#
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
                                                           ) ) ) )
                   
                             ((tailap? (first code))
                              (define closure (op-stack 'pop!)) ;; (define closure (first (rest stack)))
          
                              (make-secd op-stack
                                         (extend-environment
                                          (closure-environment closure)
                                          (closure-variable closure)
                                          (op-stack 'pop!))    
                                         (closure-code closure)
                                         dump)))
   
                             (begin
                           (if (empty? (rest code))
                               
                                (let ([ frame (first dump)])
                              (begin
                                (op-stack 'add-all!  (frame-stack frame))
                                (make-secd
                                 op-stack
                                 (frame-environment frame)
                                 (frame-code frame)
                                 (rest dump))                               
                                   (write-newline)
                                 (write-string "process-return")
                                   (write-newline)
                               (make-secd
                                               op-stack
                                                env                                  
                                                code
                                               dump
                                                )))
                               (begin
                                 (write-newline)
                                (write-string "process recursive-call")
                                  (write-newline)
                                   (if (empty? (rest code))
                                  (make-secd
                                               op-stack
                                                env                                  
                                                code
                                               dump
                                                )
                               (really-process (make-secd
                                                   op-stack
                                                env                                  
                                                (rest code)
                                               dump
                                                )))
                               ))))))                
                   

(define eval-secd (lambda (ast)
                    (let* ([fresh-stack (lambda () (make-stack (list)))]
                           [secd-mach (make-secd  (fresh-stack) (ast-env ast) (ast-code ast) (ast-dump ast))]
                           [new-frame (make-frame (fresh-stack) (ast-env ast) (ast-code ast) )]
                           [dump (append (list new-frame) (ast-dump ast))]
                           [result
                            (process (make-ast (fresh-stack) (ast-code ast) empty (ast-env ast) dump))])
                    
                      ((secd-stack result) 'pop!)
                      )))

(check-expect (eval-secd (compile-secd '((lambda (x) (mul 5 x)) 2))) 10)
;; this tiny scheme code is the level for the next step
#;(check-expect (eval-secd (compile-secd '((define test-west
                                           (lambda (x)
                                             (lambda (y)
                                             (mul x y)))
                                           )
                                         (define higher (lambda (y)
                                                          (lambda ()
                                                          (add 5 ((test-west y) 9)))))
                                         ((higher 10))))) 42) ;; replace 42 the number of wisdom
(check-expect (eval-secd(compile-secd '(((lambda (x) (lambda (y) (mul y  (add x y)))) 1) 2))) 6)   
;;(check-expect (eval-secd(compile-secd '(((lambda (x) (lambda (y) (div 120 (mul y  (add x y) ) )) 1) 2)))) 20)
