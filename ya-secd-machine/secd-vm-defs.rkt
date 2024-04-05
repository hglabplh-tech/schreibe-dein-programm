#lang deinprogramm/sdp/advanced

(require
  (only-in      lang/htdp-advanced
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
  "stack.rkt")
  
;;(list-data? 5)
;;(list-data?  '(6 7 8 9))
;;(list-data?  '(6))
;;(cons?  '(6))
;;lang/htdp-advanced
  

(provide make-binding
         binding
         binding?
         make-binding
         binding-variable
         binding-value
         the-empty-environment
         extend-environment
         remove-environment-binding
         lookup-environment
         lookup-act-environment
         make-empty-frame
         make-frame
         frame?
         frame-stack
         frame-fun-stack 
         frame-environment
         frame-code
         term
         abstraction?
         application?
         var-value
         secd
         make-secd
         secd-stack
         secd-fun-stack
         secd-environment
         secd-code
         secd-dump
         make-closure
         closure-environment
         closure-variable
         closure-code
         closure?
         base base?
         make-ap
         ap ap?
         make-tailap
         tailap tailap?
         make-prim
         prim? prim
         prim-operator
         prim-arity
         op
         make-op
         op?
         op-operation
         op-code
         op-params
         op-stack-arity
         op-stack-out
         op-parm-arity
         apply-primitive
         pcode->fun
         primitive?
         primitive-application
         primitive-application?
         make-abst
         abst abst?
         abst-variable
         abst-code
         op-code-syms
         ast
         make-ast ast?
         ast-stack
         ast-code
         ast-next 
         ast-env  
         ast-dump
         op-code?
         instruction
         machine-code  
         make-exec
         exec?
         smart-first
         smart-rest
         definable
         definition?
         define-val
         define-def
         define-def?
         define-def-bind
         define-def-value   
         make-define-def
         eval-param
         fun-application?
         app-fun
         app-fun?
         make-app-fun
         app-fun-variable
         app-fun-code
         var-symbol?       
         stack-element
         make-stack-element
         stack-element?
         stack-element-type
         stack-element-value
         new-stack-element
         where?
         where-condition?
         make-where?
         where?-?
         where?-condition
         where?-if-branch
         where?-else-branch
         )

;;Hier der "Prozessor" Befehlssatz
(define op-code-syms '(  push pop peek create-const
                              load-const store-const alloc free svc-open svc-read
                              svc-write svc-close
                              read write
                              store load lambda let branch apply eq?
                              where add mul div sub mod  sqrt exp))

(define op-code?
  (lambda (term)
    (or (equal? 'push  term)
        (equal? 'pop term)
        (equal? 'peek term)
        (equal? 'store term)
        (equal? 'load term)
        )))

(define primitive?
  (lambda (term)
    (or (equal? 'add  term)
        (equal? 'sub term)
        (equal? 'mul term)
        (equal? 'div term)
        (condition-primitive? term))))
       

(: condition-primitive? (any -> boolean))
(define condition-primitive?
  (lambda (term)
    (or (equal? '== term)
        (equal? '> term)
        (equal? '< term)
        (equal? '>= term)
        (equal? '<= term)
        (equal? 'true? term)
        (equal? 'false? term)
        )
    ))

(define instruction
  (signature
   (mixed 
    base
    var-symbol
    op
    ap
    tailap
    prim
    complex-form
    define-def
    apply-fun
    abst
    where?)))

(define complex-form-instruction
  (signature
   (mixed
    base
    var-symbol 
    prim
    stop
    )))

;; here we define the stuff for machine-code; Applikations-Instruktion
(define-record exec
  make-exec exec?)

; Applikations-Instruktion
(define-record ap
  make-ap ap?
  )

; Eine endrekursive Applikations-Instruktion ist ein Wert
;   (make-tailap)
(define-record tailap
  make-tailap tailap?
  )

(define-record stop
  make-stop stop?)

; Eine Abstraktions-Instruktion hat folgende Eigenschaften:
; - Parameter (eine Variable)
; - Code für den Rumpf
(define-record abst
  make-abst abst?
  (abst-variable  var-symbol)
  (abst-code machine-code))

(define eval-param (lambda (term)
                     (if (empty? term)
                         'no-parm-nop
                         (first term))))

; Eine Deefinitions-Instruktion hat folgende Eigenschaften:
; -  Ein Bezeichner
; -  ein Symbol ein Base eine Abstraction eine Applikation... 
(define-record define-def
  make-define-def  define-def?
  (define-def-bind var-symbol)
  (define-def-value define-val))

(define definable (signature (mixed abst ap var-symbol base binding)))

(define define-val (signature (list-of definable)))

(define apply-fun (signature (list-of definable)))

(define var-value (signature any))

(define environment (signature (list-of binding)))

(define machine-code (signature (list-of instruction)))

(define  proc-fun (signature (predicate proc-fun?)))




(define prim-machine-code (signature (list-of complex-form-instruction)))


;;Ein Stack ist eine Liste von Werten
(define stack (signature any)) ;; ändern zum aktuellen Stand
(define dump (signature (list-of frame)))
;; Hier die Definition der Umgebung
; Eine Bindung besteht aus:
; - Variable
; - Wer(define stack
(define-record binding
  make-binding binding?
  (binding-variable var-symbol)
  (binding-value var-value))


(define-record stack-element
  make-stack-element stack-element?
  (stack-element-type var-symbol)
  (stack-element-value var-value))
; Ein Frame besteht aus:
; - Stack
; - Umgebung
; - Code
(define-record frame
  make-frame frame?
  (frame-stack stack)
  (frame-fun-stack stack)
  (frame-environment environment)
  (frame-code machine-code))



; Eine Closure besteht aus:
; - Variable
; - Code
; - Umgebung
(define-record closure
  make-closure closure?
  (closure-variable var-symbol)
  (closure-code machine-code)
  (closure-environment environment))

; Ein SECD-Zustand besteht aus:
; - Stack
; - Umgebung
; - Code
; - Dump
(define-record secd
  make-secd secd?
  (secd-stack stack)
  (secd-fun-stack stack)
  (secd-environment environment)
  (secd-code machine-code)
  (secd-dump dump))

; Eine Instruktion für eine primitive Applikation hat folgende
; Eigenschaften:
; - Operator
; - Stelligkeit
(define-record prim
  make-prim prim?
  (prim-operator symbol)
  (prim-arity natural))



; Eine Instruktion für eine Funktions Applikation hat folgende
; Eigenschaften:
; - Bezeichner
; - Stelligkeit
(define-record app-fun
  make-app-fun app-fun?
  (app-fun-variable var-symbol)
  (app-fun-code machine-code))

(define-record where?
  make-where? where?-?
  (where?-condition machine-code) 
  (where?-if-branch machine-code)
  (where?-else-branch machine-code))

(define-record complex-form
  make-complex-form complex-form?
  (complex-form-prim prim)
  (complex-form-prim-child  machine-code))


; Eine Instruktion für generelle Anwendung
; Eigenschaften:
; - Operator
; - Stelligkeit - Stack
; - Anzahl der auf dem Stack ausgegebenen Ergebnis - Werte
; - Stelligkeit op parameter
(define-record op
  make-op op?  
  (op-code symbol)
  (op-operation proc-fun)
  (op-params  (list-of any))
  (op-stack-arity natural)
  (op-stack-out natural)
  (op-parm-arity natural)
  )

; Ein Basiswert ist ein boolescher Wert oder eine Zahl
; Prädikat für Basiswerte
(: base? (any -> boolean))
(define base?
  (lambda (term)
    (or (boolean? term)
        (char-data?  term)
        (byte-data?  term)
        (string? term)
        (number? term))))
        


(define base (signature (predicate base?)))
(define term
  (signature
   (mixed var-symbol
          application
          abstraction
          primitive-application
          base)))





(define pcode->fun
  (lambda (term)
    (cond
      ((equal?  term 'add)
       +)
      ((equal?  term 'sub)
       -)
      ((equal? term  'mul)
       *)
      ((equal? term  'div )
       /)  
      ((equal? term '==)
       equal?)
      ((equal? term '>)
       >)
      ((equal? term '<)
       <)
      ((equal? term '>=)
       >=)
      ((equal? term '<=)
       <=)
      )))

(define apply-primitive
  (lambda (primitive args)
    (cond
      ((equal? primitive  'add)
       (+ (first args) (first (rest args))))
      ((equal? primitive 'sub)
       (- (first args) (first (rest args))))
      ((equal? primitive 'eq?)
       (equal? (first args) (first (rest args))))
      ((equal? primitive 'mul)
       (* (first args) (first (rest args))))
      ((equal? primitive 'div)
       (/ (first args) (first (rest args))))
       ((equal? primitive '==)
       (equal? (first args) (first (rest args))))
      ((equal? primitive '>)
       (> (first args) (first (rest args))))
      ((equal? primitive '<)
       (< (first args) (first (rest args))))
      ((equal? primitive '>=)
       (>= (first args) (first (rest args))))
      ((equal? primitive '<=)
       (<= (first args) (first (rest args))))
      )))


(define primitive (signature (predicate primitive?)))

(: primitive? (any -> boolean))
; Prädikat für reguläre Applikationen
(: application? (any -> boolean))
(define application?
  (lambda (term)
    (and (cons? term)         
         (not (equal? 'lambda (first term)))       
         (not (equal? 'define (first term)))
         (not (primitive? (first term)))
         )))


(define smart-first
  (lambda (term)
    (cond
      ((cons? term)
       (first term))
      (else (first (list term)))
      )
    ))



(define smart-rest
  (lambda (term)
    (cond
      ((cons? term)
       (rest term))
      (else (rest (list term)))
      )
    ))    


(define application (signature (predicate application?)))


; Prädikat für Abstraktionen
(: definition? (any -> boolean))
(define definition? (lambda (term)
                      (equal?  term 'define)  ))



; Prädikat für Abstraktionen
(: abstraction? (any -> boolean))
(define abstraction?
  (lambda (term)
    (and (cons? term)
         (equal? 'lambda (first term))
         )))

(define abstraction (signature (predicate abstraction?)))

; Prädikat für primitive Applikationen
(: primitive-application? (any -> boolean))
(define primitive-application?
  (lambda (term)
    (and (cons? term)
         (primitive? (first term))
         )))

; Prädikat für higher order Applikationen
(: fun-application? (any -> boolean))
(define fun-application?
  (lambda (term)
    (and (cons? term)
         (equal? (first term) 'app-fun)
         )))

; Prädikat für where Bedingungen
(: where-condition? (any -> boolean))
(define where-condition?
  (lambda (term)
    (and (cons? term) 
         (equal? (first term) 'cond-branch)
         )))





(define primitive-application (signature (predicate primitive-application?)))

(define-record ast
  make-ast ast?
  (ast-stack stack)
  (ast-code machine-code)
  (ast-next machine-code)
  (ast-env  environment)
  (ast-dump dump)
  )

(define new-stack-element
  (lambda (type val)
    (make-stack-element type val)
    ))


(: the-empty-environment environment)
(define the-empty-environment empty)

; eine Umgebung um eine Bindung erweitern
(: extend-environment (environment symbol var-value -> environment))

(define  extend-environment
  (lambda (env var-symbol var-value)   
    (cons (make-binding var-symbol var-value)
          (remove-environment-binding env var-symbol)  )))

(: remove-environment-binding (environment symbol -> environment))

(define remove-environment-binding
  (lambda (environment variable)
    (cond
      ((empty? environment) empty)
      ((cons? environment)
       (if (equal? variable (binding-variable (first environment)))
           (rest environment)
           (cons (first environment)
                 (remove-environment-binding (rest environment) variable)))))))

(: lookup-act-environment (environment symbol -> var-value))

(define lookup-act-environment
  (lambda (environment variable)
    (cond
      ((empty? environment) empty)
      ((cons? environment)
       (if (equal? variable (binding-variable (first environment)))
           (binding-value (first environment))
           (lookup-act-environment (rest environment) variable))))))

(define lookup-environment
  (lambda (environment dump variable)
    (let* ((act-val (lookup-act-environment environment variable)))
      (cond ((not (empty? act-val)) act-val)
            (else  (env-lookup-helper dump variable)
                   )))))

(define env-lookup-helper (lambda (dump variable)
                            (let* ([env (frame-environment (first dump))]
                                   [binding (lookup-act-environment env variable)])
                              (if (empty? binding)
                                  (if (empty? dump)
                                      (env-lookup-helper (rest dump) variable)
                                      binding)
                                  binding
                                  ))))

(define make-empty-frame
  (lambda ()
    (make-frame empty the-empty-environment empty )))

(define new-abstract
  (lambda (closure-sym)
    ( make-closure closure-sym )
    ))

(: var-symbol? (any -> boolean))
(define var-symbol (signature (predicate var-symbol?)))
(define var-symbol?
  (lambda (term)
    (let ([token term])
      (and (symbol? token)
           (not (equal? token 'define))
           (not (equal? token 'lambda))
           (not (equal? token 'app-fun))
           (not (primitive? token))
           (not (equal? token 'where?))
           (not (equal? token 'stop))
           (not (base? token)) )
      )))
  
