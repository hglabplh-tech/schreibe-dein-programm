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
 6)