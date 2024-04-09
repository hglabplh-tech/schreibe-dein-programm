#lang deinprogramm/sdp/advanced
;; here we define some lambdas which work not correct to see that in the file they are imported the error
;; is not shown correctly

(provide  incorrect-list-proc)

(define incorrect-list-proc (lambda ()
         (first empty))
  )

;;( incorrect-list-proc)