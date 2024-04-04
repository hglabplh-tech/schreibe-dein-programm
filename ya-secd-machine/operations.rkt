#lang scheme/base
(require "secd-vm-defs.rkt"
         "stack.rkt")
(provide make-push! make-pop!)

(define push!-tmpl (make-op 'push! (lambda (the-stack value)
                                     (the-stack 'push! value)) (list) 0 1 1))
(define pop!-tmpl (make-op 'pop! (lambda (the-stack)
                                   (the-stack 'pop!)) (list) 0 0 0))
 
(define make-push! (lambda (in-values)
                     (make-op (op-code push!-tmpl)
                              (op-operation push!-tmpl)
                              in-values
                              (op-stack-arity push!-tmpl)
                              (op-stack-out push!-tmpl)
                              (op-parm-arity push!-tmpl)
                              )
                     ))

(define make-pop! (lambda ()
                    (make-op (op-code pop!-tmpl)
                             (op-operation pop!-tmpl)
                             (op-params pop!-tmpl)
                             (op-stack-arity pop!-tmpl)
                             (op-stack-out pop!-tmpl)
                             (op-parm-arity pop!-tmpl)
                             )
                    ))