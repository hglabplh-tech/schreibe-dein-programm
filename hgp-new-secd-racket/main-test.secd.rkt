((define higher (lambda (u t e)
                  (cond-branch (< t 9)
                              (apply-fun sqrt e)
                               (add t (apply-fun test-west u)
                                    ))))
 (apply-fun higher 10 5 17))