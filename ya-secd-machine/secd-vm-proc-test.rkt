#lang deinprogramm/sdp/advanced
(require "secd-compiler.rkt"
         "secd-vm-proc.rkt")

#;(check-expect (eval-secd (compile-secd
            '((define parm-test
                (lambda (x y z)
                  (mul z (add y x))))
              (apply-fun parm-test 3 4 2)))) 14)

(check-expect
 (eval-secd
  (read-analyze-compile "test-prog.secd.rkt"))
 289)

(check-expect
 (eval-secd (compile-secd
             '((define heap-test
                 (lambda (x)
                   (where-cond
                    (is? (== x 1)
                         (heap-alloc hx 5)) 
                    (is? (== x 2)
                         (heap-set-at! hx 10))
                    (is? (== x 3)
                         (mul (heap-get-at hx) 2))
                    (is? (== x 4)
                        (heap-free hx)))))
               (apply-fun heap-test 1)
               (apply-fun heap-test 2)
               (apply-fun heap-test 3)
               (apply-fun heap-test 4)))) 20)
                         