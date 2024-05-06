#lang deinprogramm/sdp/advanced

(require  (only-in      lang/htdp-advanced
                        procedure?
                        [procedure? proc-fun?])
          (only-in      lang/htdp-advanced
                        list?                   
                        [list? list-data?])
          (only-in      lang/htdp-advanced
                        char?                   
                        [char? char-data?])
          (only-in      racket
                        byte?                   
                        [byte? byte-data?])

          "secd-vm-defs.rkt")

(provide
 integer-type
 number-type
 string-type
 boolean-type
 proc-type
 byte-type
 char-type
 list-type
 get-typedef-from-tab)

;; Die durchnummerierung der  Typen

(define int-type-num 'inf?)
(define num-type-num 'num?)
(define str-type-num  'str?)
(define bool-type-num 'bool?)
(define proc-type-num 'proc?)
(define byte-type-num 'byte?)
(define chr-type-num  'chr?)
(define lst-type-num  'lst?)

;; Definitionen der Datenstruktur für Primitive (In der Maschine bekannten) Datentypen

(define integer-type (make-prim-type int-type-num integer?))
(define number-type  (make-prim-type num-type-num number?))
(define string-type  (make-prim-type str-type-num string?))
(define boolean-type (make-prim-type bool-type-num boolean?))
(define proc-type    (make-prim-type proc-type-num proc-fun?))
(define byte-type    (make-prim-type byte-type-num byte-data?))
(define char-type    (make-prim-type chr-type-num char-data?))
(define list-type    (make-prim-type lst-type-num list-data?))

(define get-typedef-from-tab
  (lambda (term)
    (cond
      ((is-integer? term)
       integer-type)
      ((is-number? term)
       number-type)
      ((is-boolean? term)
       boolean-type)
      ((is-proc-fun? term)
       proc-type)
      ((is-byte? term)
       byte-type)
      ((is-char? term)
       char-type)
      ((is-string? term)
       string-type)
      ((is-list? term)
       list-type))))
  

