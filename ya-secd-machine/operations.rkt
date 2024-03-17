#lang scheme/base
(require "vmdefs.rkt"
         "stack.rkt")
(provide make-push! make-pop!)

(define push!-tmpl (make-op 'push! (list) 0 1 1))
(define pop!-tmpl (make-op 'pop! (list) 0 0 0))
 
(define make-push! (lambda (in-values)
                    (make-op (op-code push!-tmpl)
                    in-values
                    (op-stack-arity push!-tmpl)
                    (op-stack-out push!-tmpl)
                    (op-parm-arity push!-tmpl)
                    )
                    ))

(define make-pop! (lambda (in-values)
                    (make-op (op-code pop!-tmpl)
                    (op-params pop!-tmpl)
                    (op-stack-arity pop!-tmpl)
                    (op-stack-out pop!-tmpl)
                    (op-parm-arity pop!-tmpl)
                    )
                    ))