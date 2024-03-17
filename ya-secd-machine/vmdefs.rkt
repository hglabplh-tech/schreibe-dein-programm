#lang deinprogramm/sdp/advanced

(require "stack.rkt")

(provide make-binding binding?
         the-empty-environment
         extend-environment
         remove-environment-binding
         lookup-environment
         make-empty-frame
         make-frame
         frame?
         frame-stack
         frame-environment
         frame-code
         term
         abstraction?
         application?
          var-value
         secd
         make-secd
         secd-stack
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
          op-code
          op-params
          op-stack-arity
          op-stack-out
          op-parm-arity
          apply-primitive
          primitive->pcode
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
        (equal? 'where term))))
(define primitive?
  (lambda (term)
    (or (equal? '+  term)
        (equal? '- term)
        (equal? '* term)
        (equal? '/ term)
        (equal? '% term)
        (equal? '= term))))

(define instruction
  (signature
   (mixed base
	  symbol
          op
	  ap
	  tailap
	  prim
	  abst)))

;; here we define the stuff for machine-code

; Applikations-Instruktion
(define-record ap
  make-ap ap?)

; Eine endrekursive Applikations-Instruktion ist ein Wert
;   (make-tailap)
(define-record tailap
  make-tailap tailap?)

; Eine Abstraktions-Instruktion hat folgende Eigenschaften:
; - Parameter (eine Variable)
; - Code für den Rumpf
(define-record abst
  make-abst abst?
  (abst-variable symbol)
  (abst-code machine-code))


;; Hier die Definition der Umgebung
; Eine Bindung besteht aus:
; - Variable
; - Wer(define stack


(define var-value (signature any))
(define environment (signature (list-of binding)))
(define machine-code (signature (list-of instruction)))
 ;;Ein Stack ist eine Liste von Werten
(define stack (signature any))
(define dump (signature (list-of frame)))

(define-record binding
  make-binding binding?
  (binding-variable symbol)
  (binding-value var-value))



; Ein Frame besteht aus:
; - Stack
; - Umgebung
; - Code
(define-record frame
  make-frame frame?
  (frame-stack stack)
  (frame-environment environment)
  (frame-code machine-code))



; Eine Closure besteht aus:
; - Variable
; - Code
; - Umgebung
(define-record closure
  make-closure closure?
  (closure-variable symbol)
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

; Eine Instruktion für generelle Anwendung
; Eigenschaften:
; - Operator
; - Stelligkeit - Stack
; - Anzahl der auf dem Stack ausgegebenen Ergebnis - Werte
; - Stelligkeit op parameter
(define-record op
  make-op op?  
  (op-code symbol)
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
        (number? term))))

(define base (signature (predicate base?)))
(define term
  (signature
   (mixed symbol
	  application
	  abstraction
	  primitive-application
          base)))



(define primitive->pcode
  (lambda (term)
    (cond
     ((equal?  term (first (list '+ 'add)))
     'add)
       ((equal? term  (first (list '- 'sub )))
     'sub)
      ((equal? term  (first (list '* 'mul )))
     'mul)
      ((equal? term  (first (list '/ 'div )))
     'div)
       ((equal? term  (first (list '%  'mod )))
     'mod)    
      ((equal? term  (first (list '= 'eq? )))
     'eq?))))

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
      ((equal? term 'eq?)
     equal?))))

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
       (/ (first args) (first (rest args)))))))


(define primitive (signature (predicate primitive?)))

(: primitive? (any -> boolean))
; Prädikat für reguläre Applikationen
(: application? (any -> boolean))
(define application?
  (lambda (term)
    (and (cons? term)
         (not (equal? 'set! (first term)))
         (not (equal? 'lambda (first term)))
         (not (primitive? (first term))))))

(define application (signature (predicate application?)))

; Prädikat für Abstraktionen
(: abstraction? (any -> boolean))
(define abstraction?
  (lambda (term)
    (and (cons? term)
         (equal? 'lambda (first term)))))

(define abstraction (signature (predicate abstraction?)))

; Prädikat für primitive Applikationen
(: primitive-application? (any -> boolean))
(define primitive-application?
  (lambda (term)
    (and (cons? term)
         (primitive? (first term)))))

(define primitive-application (signature (predicate primitive-application?)))

(define-record ast
  make-ast ast?
  (ast-stack stack)
  (ast-code machine-code)
  (ast-next machine-code)
  (ast-env  environment)
  (ast-dump dump)
  )


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

(: lookup-environment (environment symbol -> var-value))

(define lookup-environment
  (lambda (environment variable)
    (cond
      ((empty? environment) (violation "unbound variable"))
      ((cons? environment)
       (if (equal? variable (binding-variable (first environment)))
           (binding-value (first environment))
           (lookup-environment (rest environment) variable))))))

(define make-empty-frame
 (lambda ()
   (make-frame empty the-empty-environment empty )))

(define new-abstract
  (lambda (closure-sym)
    ( make-closure closure-sym )
    ))
  
