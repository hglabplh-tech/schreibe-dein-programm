(()
 ((define calc-base
                    (lambda (x)
                      (mul x (div ((app-fun higher 5)) 2))
                      ))
                  (define test-west
                    (lambda (x)
                      (cond-branch (< u 9)
                                   (mul x 18)
                                   (add 2 (app-fun calc-base 3)))))
 ))
