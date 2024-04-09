#lang deinprogramm/sdp/advanced

(require "incorrect-utils.rkt")

;; let test with return empty is there a bug in parser
;; correct let
(let ([x (+ 3 9)])
  x
  )

;; probably incorrect let

(define test-let (lambda (i)
                   (begin
                   (+ i 9)
          empty ;; accidentally returns empty .... now we call it in a let          
          )))

(begin (let ([result (test-let 10)])
  result))

;;; This above was not the reason for the irritation it works as designed
;; now here some stuff where we need a second file which is imported  via require

;; the function we call contains a 'no cons' error in cause of (first empty)

(check-expect  ((let ([result ( incorrect-list-proc)])
  result
  )) 9)

;; if check-expect is used the error is shown in a way as it is in this file.. There is no stack tracing possible
;; except we call it without check-expect - maybe is there a checker which works in a way there it is shown ?

;;(let ([result ( incorrect-list-proc)])
  ;;result
  ;;
;;) if we call it without check-expect the correct stacktrace is shown and the message is clear