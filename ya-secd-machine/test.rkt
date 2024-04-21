#lang deinprogramm/sdp/advanced
(define the-lambda-test
  (lambda (x)
    (lambda (y)
      (lambda (z)
        (+ x y z)
    ))))

(the-lambda-test 7)
((the-lambda-test 7) 5)
(((the-lambda-test 7) 5) 2)

(define call-the-test
  (lambda (x y z)
    (((the-lambda-test x) y) z)
    )
  )

(call-the-test 10 20 30)