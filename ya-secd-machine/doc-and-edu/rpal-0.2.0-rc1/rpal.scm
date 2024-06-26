;; RPAL - An interpreter for the Right-reference Pedagogic Algorithmic Language
;; Copyright (C) 2006 Daniel Franke
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

(define *failure-mode* #f)
(define *panic-cc* '())

(define (rpal-print x)
  (cond ((null? x) (display "nil"))
        ((number? x) (display x))
        ((eq? x #t) (display "true"))
        ((eq? x #f) (display "false"))
        ((string? x) (display x))
        ((list? x) (begin
                     (display "(")
                     (letrec ((foo (lambda (x)
                                     (rpal-print (car x))
                                     (if (not (null? (cdr x)))
                                         (begin
                                           (display ",")
                                           (foo (cdr x)))))))
                                (foo x))
                              (display ")")))
                 ((procedure? x) (display "#<fn>"))
                 ((eq? x 'dummy) (display "dummy")))
  'dummy)

(define (fail line msg . args)
  (if (not (eq? #f line))
      (begin 
        (display (number->string line))
        (display ": ")
        (display msg)
        (set! *failure-mode* #t))
      (begin
        (display "Runtime error: ")
        (display msg)))
  (display "\n")
  (if (not (null? args))
      (begin
        (display "Parameter(s) was:\n")
        (for-each (lambda (arg)
                    (rpal-print arg)
                    (display "\n")) args)))
  (if (eq? #f line) (if (null? *panic-cc*) (exit) (*panic-cc*))))

(define (rpal-isinteger x) (number? x))
(define (rpal-istruthvalue x) (boolean? x))
(define (rpal-isstring x) (string? x))
(define (rpal-istuple x) (list? x))
(define (rpal-isfunction x) (procedure? x))
(define (rpal-isdummy x) (eq? x 'dummy))
(define (rpal-stem x) (if (string? x)
                          (if (= (string-length x) 0)
                              "" (substring x 0 1))
                          (fail #f "Argument to Stem is not a string")))
(define (rpal-stern x) (if (string? x)
                           (if (= (string-length x) 0)
                               "" (substring x 1 (string-length x)))
                           (fail #f "Argument to Stern is not a string")))
(define (rpal-conc x)
  (lambda (y)
    (if (and (string? x) (string? y))
        (string-append x y)
        (fail #f "Argument to Conc is not a string"))))
(define (rpal-order x) (if (list? x)
                           (length x)
                           (fail #f "Argument to Order is not a tuple")))
(define (rpal-itos x) (if (number? x)
                          (number->string x)
                          (fail "Argument to Itos is not an integer")))
(define (rpal-null x) (null? x))

(define (lookup sym tab)
  (let ((val (assoc (car sym) tab)))
    (if (eq? val #f)
        (fail (cadr sym) (string-append "Unbound identifier " (car sym)))
        (cdr val))))

(define basetab `(("Y*" . rpal-y) ;It's impossible to get this from the lexer,
                                  ;so we're not polluting the namespace.
                  ("Print" . rpal-print)
                  ("Isinteger" . rpal-isinteger)
                  ("Istruthvalue" . rpal-istruthvalue)
                  ("Isstring" . rpal-isstring)
                  ("Istuple" . rpal-istuple)
                  ("Isfunction" . rpal-isfunction)
                  ("Isdummy" . rpal-isdummy)
                  ("Stem" . rpal-stem)
                  ("Stern" . rpal-stern)
                  ("Conc" . rpal-conc)
                  ("Order" . rpal-order)
                  ("ItoS" . rpal-itos)
                  ("Null" . rpal-null)))

(define rpal-y
  (lambda (X)
    ((lambda (procedure)
       (X (lambda (arg) ((procedure procedure) arg))))
     (lambda (procedure)
       (X (lambda (arg) ((procedure procedure) arg)))))))

(define-syntax rpal-list-aux
  (syntax-rules (rpal-list-aux)
    ((rpal-list-aux) '())
    ((rpal-list-aux elt) (list (lambda () elt)))
    ((rpal-list-aux elt rest ...) (cons (lambda () elt)
                                        (rpal-list-aux rest ...)))))
(define-syntax rpal-list
  (syntax-rules (rpal-list)
    ((rpal-list) '())
    ((rpal-list elt) (list elt))
    ((rpal-list elt rest ...)
     (reverse (map (lambda (x) (apply x '()))
                   (reverse (rpal-list-aux elt rest ...)))))))

(define (genst tree tab)
  (define nodes
    `((<identifier> . ,(lambda (sym)
                         (lookup sym tab)))
      (<string> . ,(lambda (str) (car str)))
      (<integer> . ,(lambda (int) (car int)))
      (let . ,(lambda (s t)
                (let ((x (genst s tab)))
                  (genst `(gamma (lambda ,(list (car x)) ,t) ,(cdr x)) tab)))) 
      (lambda
          .
        ,(lambda (formals body)
           (if (null? formals)
               (genst body tab)
               (cond
                ((eq? (caar formals) '<identifier>)
                 (let* ((newsym (gensym))
                        (newstr (caadar formals))
                        (newtab (cons (cons newstr newsym) tab)))
                   `(lambda (,newsym)
                      ,(genst `(lambda ,(cdr formals) ,body) newtab))))
                ((eq? (caar formals) 'empty)
                 `(lambda (,(gensym))
                    ,(genst `(lambda ,(cdr formals) ,body) tab)))
                ((eq? (caar formals) 'comma)
                 (let* ((arglist (map caadr (cdar formals)))
                        (newtab (append (map (lambda (x) (cons x (gensym)))
                                             arglist) tab)))
                   (letrec ((bl (lambda (args index)
                                  (if (null? args)
                                      '()
                                      (cons (list (car args)
                                                  `(list-ref x ,index))
                                            (bl (cdr args) (+ index 1)))))))
                     `(lambda (x)
                        (cond
                         ((not (list? x))
                          (fail #f "Function expected a tuple argument" x))
                         ((< (length x) ,(length arglist))
                          (fail #f (string-append
                                    "Expected a tuple of order "
                                    (number->string ,(length arglist))) x))
                         (else
                          (let ,(bl (map (lambda (sym) (lookup `(,sym 0)
                                                                newtab))
                                          arglist) 0)
                            ,(genst `(lambda ,(cdr formals) ,body)
                                    newtab)))))))))))) ;Is this a record?
      (where . ,(lambda (s t)
                  (let ((x (genst t tab)))
                    (genst `(gamma (lambda ,(list (car x)) ,s) ,(cdr x)) tab))))
      (tau . ,(lambda l
                (cons 'rpal-list (map (lambda (e) (genst e tab)) l))))
      (aug . ,(lambda (s t)
                `(let ((x ,(genst s tab))
                      (y ,(genst t tab)))
                  (if (list? x)
                      (append x (list y))
                      (fail #f "Cannot aug onto non-tuple" x y)))))
      (ternary . ,(lambda (s t u)
                    `(let ((x ,(genst s tab)))
                      (if (boolean? x)
                          (if x ,(genst t tab) ,(genst u tab))
                          ;;Don't print y and z since we might not want
                          ;;the side effects.
                          (fail #f "Ternary condition is not a truthvalue"
                                x)))))
      (or . ,(lambda (s t)
               `(let ((x ,(genst s tab))
                      (y ,(genst t tab)))
                 (if (and (boolean? x) (boolean? y))
                     (or x y)
                     (fail #f "Arguments to or are not booleans" x y)))))
      (& . ,(lambda (s t)
              `(let ((x ,(genst s tab))
                     (y ,(genst t tab)))
                 (if (and (boolean? x) (boolean? y))
                     (and x y)
                     (fail #f "Arguments to & are not booleans" x y)))))
      (not . ,(lambda (s)
                `(let ((x ,(genst s tab)))
                   (if (boolean? x)
                       (not x)
                       (fail #f "Argument to not is not boolean" x)))))
      (gr . ,(lambda (s t)
               `(let ((x ,(genst s tab))
                      (y ,(genst t tab)))
                 (if (and (number? x) (number? y))
                     (> x y)
                     (fail #f "Arguments to gr are not integers" x y)))))
      (ge . ,(lambda (s t)
               `(let ((x ,(genst s tab))
                      (y ,(genst t tab)))
                  (if (and (number? x) (number? y))
                      (>= x y)
                      (fail #f "Arguments to ge are not integers" x y)))))
      (ls . ,(lambda (s t)
               `(let ((x ,(genst s tab))
                      (y ,(genst t tab)))
                  (if (and (number? x) (number? y))
                      (< x y)
                      (fail #f "Arguments to ls are not integers" x y)))))
      (le . ,(lambda (s t)
               `(let ((x ,(genst s tab))
                      (y ,(genst t tab)))
                  (if (and (number? x) (number? y))
                      (<= x y)
                      (fail #f "Arguments to le are not integers" x y)))))
      (eq . ,(lambda (s t)
               `(equal? ,(genst s tab) ,(genst t tab))))
      (ne . ,(lambda (s t)
               `(not (equal? ,(genst s tab) ,(genst t tab)))))
      (+ . ,(lambda (s t)
              `(let ((x ,(genst s tab))
                     (y ,(genst t tab)))
                 (if (and (number? x) (number? y))
                     (+ x y)
                     (fail #f "Arguments to + are not integers" x y)))))
      (- . ,(lambda (s t)
              `(let ((x ,(genst s tab))
                     (y ,(genst t tab)))
                 (if (and (number? x) (number? y))
                     (- x y)
                     (fail #f "Arguments to - are not integers" x y)))))
      (neg . ,(lambda (s)
                `(let ((x ,(genst s tab)))
                   (if (number? x)
                       (- x)
                       (fail #f "Argument to neg in not an integer" x)))))
      (* . ,(lambda (s t)
              `(let ((x ,(genst s tab))
                     (y ,(genst t tab)))
                 (if (and (number? x) (number? y))
                     (* x y)
                     (fail #f "Arguments to * are not integers" x y)))))
      (/ . ,(lambda (s t)
              `(let ((x ,(genst s tab))
                     (y ,(genst t tab)))
                 (if (and (number? x) (number? y))
                     (quotient x y)
                     (fail #f "Arguments to / are not integers" x y)))))
      (** . ,(lambda (s t)
               `(let ((x ,(genst s tab))
                      (y ,(genst t tab)))
                  (if (and (number? x) (number? y))
                      (expt x y)
                      (fail #f "Arguments to ** are not integers" x y)))))
      (at . ,(lambda (s t u)
               (genst `(gamma (gamma ,t ,s) ,u) tab)))
      (true . ,(lambda () #t))
      (false . ,(lambda () #f))
      (nil . ,(lambda () ''()))
      (dummy . ,(lambda () 'dummy))
      (gamma . ,(lambda (s t)
                  `(let ((func ,(genst s tab))
                        (arg ,(genst t tab)))
                     (cond ((procedure? func) (func arg))
                           ((list? func)
                            (if (number? arg)
                                (if (>= (length func) arg)
                                    (list-ref func (- arg 1))
                                    (fail #f "Tuple too short" func arg))
                                (fail #f "Argument to tuple is not a number"
                                      func arg)))
                           (else (fail #f "Attempted to apply invalid Rator"
                                       func arg)))))) 
      (and . ,(lambda s
                (genst `(= ,(cons 'comma
                                  (map (lambda (x) (car (genst x tab))) s))
                           ,(cons 'tau
                                 (map (lambda (x) (cdr (genst x tab))) s)))
                       tab)))
      (rec . ,(lambda (s)
                (let ((x (genst s tab)))
                  (genst `(= ,(car x) (gamma (<identifier> ("Y*" 0))
                                             (lambda ,(list (car x))
                                                     ,(cdr x)))) tab))))
      (within . ,(lambda (s t)
                   (let ((x (genst s tab))
                         (y (genst t tab)))
                     (genst `(= ,(car y) (gamma (lambda ,(list (car x))
                                                  ,(cdr y))
                                                ,(cdr x))) tab))))
      (= . ,(lambda (s t) (cons s t)))
      (fcn_form . ,(lambda (p v e)
                     (genst `(= ,p (lambda ,v ,e)) tab))))) 
  (let* ((node (car tree))
         (val (assoc node nodes)))
    (if (eq? val #f)
        (begin
          (display (string-append "Unrecognized AST node "
                                  (symbol->string node)
                                  ". Bailing out.\n"))
          (exit))
        (apply (cdr val) (cdr tree)))))

(define (gen-scm-tree astree)
  (set! *failure-mode* #f)
  (let ((stree (genst astree basetab)))
    (if *failure-mode* #f stree)))

(define (interactive-eval stree)
  (call-with-current-continuation 
   (lambda (cc)
      (set! *panic-cc* cc)
      (rpal-print (eval stree (interaction-environment)))
      (set! *panic-cc* '()))))
