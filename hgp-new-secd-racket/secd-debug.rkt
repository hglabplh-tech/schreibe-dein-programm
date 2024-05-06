#lang racket
(require rnrs/io/ports-6
         "secd-vm-defs.rkt"
         "debug-out.rkt"
         "secd-vm-proc.rkt"
         "secd-compiler.rkt"
         "stack.rkt"
         "operations.rkt")

(provide
   
 )


(define process-thread
  (lambda ()
    (begin
      (let ([ast-rec (channel-get debug-channel)]
            [debug-inf (channel-get debug-channel)]
            )
        (eval-secd ast-rec)))))

(define start-debug-thread
  (lambda (ast debug-inf)
    (begin
      (set-debug-on! #t)
      (thread process-thread)
      (channel-put debug-channel ast)
      (channel-put debug-channel debug-inf)
      (write-object-nl "Type a debug command: ")
      (let the-loop ([input (read-line (standard-input-port))])
        (if (equal? input "quit")
            'exit
            (begin
            (channel-put debug-channel input)
            (write-object-nl "Type a debug command: ")
            (the-loop (read-line (standard-input-port))))
        )
      ))))

(define debug-main
  (lambda (fname)
    (let ([ast-rec (read-analyze-compile fname)]
          [info-rec (make-debug-info (list abst? where? app-fun?) #f)])
(start-debug-thread ast-rec info-rec))))

(debug-main "test-prog.secd.rkt")


