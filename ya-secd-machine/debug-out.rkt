#lang deinprogramm/sdp/advanced
(require
  (only-in   racket
             print
             [print debug-print])
  "secd-vm-defs.rkt"
  "stack.rkt"
  "operations.rkt")

(provide
 debug-snap-stack
 debug-snap-env
 debug-snap-frame
 debug-snap-dump
 debug-to-print-cl
 debug-to-print-app-fun
 debug-to-print-abst
 write-object-nl
 debug-to-print-secd
 print-stack-env-code
 debug-snap-heap
 )

(define debug-snap-stack
  (lambda (op-stack   message)
    (begin
      (write-object-nl message)
      (op-stack 'print-stack)
      )))

(define debug-snap-env
  (lambda (act-env message)
    (begin
      (write-object-nl message)
      (write-newline)          
      (debug-print "------ Begin Actual Env --------------")
      (write-newline)
      (if (not (empty? act-env))      
          (for-each (lambda (bind)
                      (begin
                        (write-newline)
                        (debug-print "------ Begin Binding --------------")
                        (write-newline)
                        (debug-print (binding-variable bind))
                        (write-newline)
                        (debug-print (binding-value bind))
                        (write-newline)
                        (debug-print "------ End Binding --------------")
                        (write-newline)))
                    act-env)
          (write-newline))
      (debug-print "------ End Actual Env --------------")
      (write-newline)
      )))

(define debug-snap-heap
  (lambda (the-heap-rec message)
    (let ([the-heap (heap-storage the-heap-rec)])
    (begin
      (write-object-nl message)
      (write-newline)          
      (debug-print "------ Begin The Heap --------------")
      (write-newline)
      (if (not (empty? the-heap))      
          (for-each (lambda (bind)
                      (begin
                        (write-newline)
                        (debug-print "------ Begin Heap Cell --------------")
                        (write-newline)
                        (debug-print (heap-cell-variable bind))
                        (write-newline)
                        (debug-print (heap-cell-init-value bind))
                        (write-newline)
                        (debug-print "------ End Heap Cell --------------")
                        (write-newline)))
                    the-heap)
                    (write-newline))
      (debug-print "------ End The Heap --------------")
      (write-newline)
      ))))

(define debug-snap-frame
  (lambda (frame message)
    (begin
      (write-object-nl message)
    
      (write-object-nl "------ Begin Frame Stack --------------")
      (debug-snap-stack (frame-stack frame) message)
      (write-object-nl "------ End Frame Stack --------------") 
     
      (write-object-nl"------ Begin Frame Code --------------")
      (write-object-nl (frame-code frame))
      (write-object-nl "------ End Frame Code --------------")  
     
      (write-object-nl "------ Begin Frame Environment --------------")
      (debug-snap-env (frame-environment frame) message)
      (write-object-nl "------ End Frame Environment --------------")
     
      )))

(define debug-snap-dump
  (lambda (dump message)
    (begin
      (write-object-nl message)
      (if (not (empty? dump))      
          (for-each (lambda (frame)
                      (debug-snap-frame frame message))
                    dump)
          (write-newline)
          ))))

(define debug-to-print-cl
  (lambda (cl message)    
    (begin
      (write-object-nl message)
      (write-newline)
      (write-object-nl "------ Begin Function Closure --------------")
      
      (write-object-nl (closure-variable cl))
      
      (write-object-nl (closure-code cl))
     
      (debug-snap-env (closure-environment cl) message)
      
      (write-object-nl "-------- End Function Closure --------------")
    
      )))

(define debug-to-print-app-fun
  (lambda (app-fun-rec message)
    (begin
      (write-object-nl message)
     
      )))

(define debug-to-print-abst
  (lambda (abst-rec message)
    (begin
      (write-object-nl message)
      (debug-print "------ Begin Abstraction--------------")
      (write-newline)
      (debug-print (abst-variable abst-rec))
      (write-newline)
      (debug-print (abst-code abst-rec))
      (write-newline)
      (debug-print "------ End Abstraction --------------")
      (write-newline)
      )))

(define debug-to-print-secd
  (lambda (secd-rec message)
    (begin
      (write-object-nl message)
      (write-object-nl  "------------ Begin SECD --------------------")
      (write-object-nl  "------------ Begin SECD OP STACK  --------------------")
      (debug-snap-stack (secd-stack secd-rec) message)
      (write-object-nl  "------------ End SECD OP STACK  --------------------")

      (write-object-nl  "------------ Begin SECD FUN STACK  --------------------")
      (debug-snap-stack (secd-fun-stack secd-rec) message)
      (write-object-nl  "------------ End SECD FUN STACK  --------------------")
    
      (debug-snap-stack (secd-stack secd-rec) message)
      (write-object-nl  "------------ Begin SECD ENV --------------------")
      (debug-snap-env (secd-environment secd-rec) message)
      (write-object-nl  "------------ End SECD ENV --------------------")
      (write-object-nl  "------------ Begin SECD  CODE--------------------")
      (debug-print (secd-code secd-rec))
      (write-object-nl  "------------ End SECD CODE--------------------")
      (debug-snap-dump (secd-dump secd-rec) message)
      (write-object-nl  "------------Begin SECD Heap--------------------")
      (debug-snap-heap (secd-heap secd-rec) message)
       (write-object-nl  "------------End SECD Heap--------------------")
        (write-object-nl  "------------End SECD -------------------------")
      )))

(define write-object-nl
  (lambda (message)
    (begin
      (write-newline)
      (debug-print message)
      (write-newline)
      )))

(define print-stack-env-code
  (lambda (op-stack fun-stack env code message)
    (begin
     (write-object-nl  "------------ Begin ACT OP STACK  --------------------")
      (debug-snap-stack op-stack message)
      (write-object-nl  "------------ End ACT OP STACK  --------------------")

      (write-object-nl  "------------ Begin ACT FUN STACK  --------------------")
      (debug-snap-stack fun-stack message)
      (write-object-nl  "------------ End ACT FUN STACK  --------------------")
      
         (write-object-nl  "------------ Begin ACT ENV --------------------")
      (debug-snap-env env message)
      (write-object-nl  "------------ End ACT ENV --------------------")

           (write-object-nl  "------------ Begin ACT CODE --------------------")
      (write-object-nl  code)
      (write-object-nl  "------------ End ACT CODE --------------------")
      )))