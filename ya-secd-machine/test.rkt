#lang deinprogramm/sdp/advanced

(require (only-in     racket
               assoc
               )
         (only-in     racket
               remove
               )
         )
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

(cons? '())
(cons? '(1))
(empty? '())


(define the-strange-list '(5))
(define next (rest the-strange-list))
(write-string "result 1: (cons? next)")
(write-newline)
(cons? next)
(write-newline)
(write-string "result 1: (empty? next)")
(write-newline)
(empty? next)

(define what (cons empty empty))
(cons? what)
(empty? what)

(define neckar-checker '((y 2) (x 3)))
(assoc 'x neckar-checker)
(define this-is-the-end (remove 'x neckar-checker (lambda (key element)
                                                    (equal? key (first element) ))))
(list this-is-the-end)
                                                    
  