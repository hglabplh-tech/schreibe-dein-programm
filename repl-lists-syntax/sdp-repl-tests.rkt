#lang deinprogramm/sdp/advanced

(require (only-in racket
         display car cdr))
(define simple-num-list '(1 3 4 5 6))
(define simple-sym-list '(hi das   klar passt in))

(define simple-num-list-2 (list 12 32 42 53 68))
(define simple-sym-list-2 (list 'hi 'das   'klar 'passt 'in))

(define check-num
  (lambda (lst)
    (if (empty? lst)
    'ready
        (begin
           (display (car lst))
    (display (integer? (car lst)))
    (check-num (cdr lst))))))

(define check-sym
  (lambda (lst)
    (if (empty? lst)
    'ready
        (begin
          (display (car lst))
    (display (symbol? (car lst)))
    (check-sym (cdr lst))))))

(define check-sym-why
  (lambda (lst index)
    (if (eq? index -1)
    'ready
        (begin
          (display (list-ref lst index))
    (display (symbol? (list-ref lst index)))
    (check-sym-why lst (- index 1))))))

#;(define check-sym
  (lambda (lst)
    (if (empty? lst)
    'ready
        (begin          
    (display ( (car lst)))
    (check-num (cdr lst))))))
    
(check-num simple-num-list)
(check-sym simple-sym-list)
(check-num simple-num-list-2)
(check-sym simple-sym-list-2)
(check-sym-why simple-sym-list (- (length simple-sym-list) 1))
(symbol? (list-ref simple-sym-list 2))