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
         make-frame
         frame?
         frame-stack
         frame-fun-stack 
         frame-environment
         frame-code
         term
         abstraction?
         more-abstraction?
         application?
         var-value
         secd
         make-secd
         secd-stack
         secd-fun-stack
         secd-environment
         secd-code
         secd-dump
         secd-heap
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
         smart-first
         smart-rest
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
       ;;  app-fun-variable
        ;; app-fun-code
         var-symbol?       
         stack-element
         make-stack-element
         stack-element?
         stack-element-type
         stack-element-value
         new-stack-element
         where
         where-condition?
         make-where
         where?
         where?-condition
         where?-if-branch
         where?-else-branch
         heap-assignment?
         heap-set-at!
         make-heap-set-at!
      heap-set-at!?
      heap-cell
      heap-cell?
      make-heap-cell
      heap-cell-variable
      heap-cell-init-value
       make-heap-get-at
       heap-allocator?
       heap-alloc
      heap-alloc?
      make-heap-alloc      
      heap-get-at
      heap-get-at?
      heap-getter
       heap-getter?
      heap
      heap?
      make-heap
      heap-storage
      extend-heap-stor
      lookup-heap-stor
      is-where?
      is
      is?
      single-cond
      make-single-cond
      single-cond?
      single-cond-what
      single-cond-code
      conditions
      make-conditions
      conditions?
      conditions-conds
      begin-it?
      code-block
      make-code-block
      code-block?
      code-block-code
      break
    break?
    make-break
    rest-or-empty
         )

;;Hier der "Prozessor" Befehlssatz - als Idee
(define op-code-syms '(  push pop peek create-const
                              load-const store-const alloc free svc-open svc-read
                              svc-write svc-close
                              read write
                              store load lambda let branch apply eq?
                              where add mul div sub mod  sqrt exp))


;; Für spätere Benutzung

(define op-code?
  (lambda (term)
    (or (equal? 'push  term)
        (equal? 'pop term)
        (equal? 'peek term)
        (equal? 'store term)
        (equal? 'load term)
        )))

;; Hir kommt die Sektion der "Primitiven Applikationen" das sind Operationen
;; welche direkkt in die Sprache eingebettet sind

(define primitive (signature (predicate primitive?)))

(: primitive? (any -> boolean))
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
;; Ende der Definitionen für Primitive Application


;; die instructionen sind die Befehle / Definitionen die die "VM" kennt 
(define instruction
  (signature
   (mixed 
    base
    var-symbol
    op
    ap
    tailap
    prim    
    define-def
    app-fun
    abst
    where
    single-cond
    heap-set-at!
    heap-get-at
    heap-alloc
    single-cond
    conditions
    )))




; Applikations-Instruktion
(define-record ap
  make-ap ap?
  )

; Eine endrekursive Applikations-Instruktion ist ein Wert
;   (make-tailap)
(define-record tailap
  make-tailap tailap?
  )

; Eine Abstraktions-Instruktion hat folgende Eigenschaften:
; - Parameter (eine Variable)
; - Code für den Rumpf
(define-record abst
  make-abst abst?
  (abst-variable  var-symbol)
  (abst-code machine-code))

(define eval-param (lambda (term)
                     (if (symbol? (smart-first term))
                          (smart-first term)
                         '++_no_parm)))


(define rest-or-empty
  (lambda (token)
    (if (and (cons? token
                    )(cons? (rest token)))
        (rest token)
        (list)
        )))

; Eine Deefinitions-Instruktion hat folgende Eigenschaften:
; -  Ein Bezeichner
; -  ein Symbol ein Base eine Abstraction eine Applikation... 
(define-record define-def
  make-define-def  define-def?
  (define-def-bind var-symbol)
  (define-def-value define-val))

;; verschiedene benötigte Signaturen


(define define-val (signature term))

(define var-value (signature any))

(define environment (signature (list-of binding)))

(define machine-code (signature (list-of instruction)))

(define  proc-fun (signature (predicate proc-fun?)))

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

;; dieser record is für die später komplett typisierte Speicherung von Werten auf dem Stack (noch nicht
;; vollendet)
(define-record stack-element
  make-stack-element stack-element? 
  (stack-element-type var-symbol) ;; change signature
  (stack-element-datatype any);;change signature
  (stack-element-value any)) ;; change to typed

;; hier kommt die internen Definitionen einer Zuweisung

;; Definition einer Zuweisung
; Eine Zuweisungs-Instruktion ist ein Wert
; diese Definitionen habe ich der Einfacheit halber teilweise von Mike Sperber übernommen

;; Definition wie ie Zuweisung im Code aussieht

;; Signaturen für Heap Operationen
(define heap-assignment (signature (predicate heap-assignment?)))
(define heap-allocatur (signature (predicate heap-allocator?)))
(define heap-getter (signature (predicate heap-getter?)))



(: heap-allocator? (any -> boolean))
(define heap-allocator?
  (lambda (term)
    (and (cons? term)
         (equal? 'heap-alloc (first term)))))

(define heap-allocator (signature (predicate heap-allocator?)))

(: heap-assignment? (any -> boolean))
(define heap-assignment?
  (lambda (term)
    (and (cons? term)
         (equal? 'heap-set-at! (first term)))))

(: heap-getter? (any -> boolean))
(define heap-getter?
  (lambda (term)
    (and (cons? term)
         (equal? 'heap-get-at (first term)))))



;; Rekord für eine heap Zuweisung // Getter / Allocator
(define-record  heap-alloc
  make-heap-alloc heap-alloc? )

(define-record  heap-set-at!
  make-heap-set-at! heap-set-at!? )

(define-record  heap-get-at
  make-heap-get-at heap-get-at? )



;; Die für den Heap notwendigen Definitionen eines

;; Definition einer Zelle die auf dem Heap liegt
(define-record heap-cell
              make-heap-cell heap-cell?
               (heap-cell-variable var-symbol)
               (heap-cell-init-value base) ;; change to typed
              )

;; Der Heap an sich

(define heap-content (signature (list-of heap-cell)))

(define-record heap
  make-heap heap?
  (heap-storage heap-content))

;; Heap Alloc Signatur


;; Definition eines heap Element

; Ein Frame besteht aus:
; - Stack
;; Stack für Abstractionen / Closures
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
;; Stack für Abstractionen / Closures
; - Umgebung
; - Code
; - Dump
(define-record secd
  make-secd secd?
  (secd-stack stack)
  (secd-fun-stack stack)
  (secd-environment environment)
  (secd-code machine-code)
  (secd-dump dump)
  (secd-heap heap)
  )

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

(define-record app-fun
  make-app-fun app-fun?)
 ;; (app-fun-variable var-symbol)
  ;;(app-fun-code machine-code))

;; Diese Struktur dient zur Darstellung eines "Conditional Branch"
(define-record where
  make-where where?
  (where?-condition machine-code) 
  (where?-if-branch machine-code)
  (where?-else-branch machine-code))

;; Definition eines Begin Blocks - Instruktions-Sequenz
(: begin-it? (any -> boolean))
(define begin-it?
  (lambda (term)
  (and (cons? term)
       (equal? 'code-block (first term)))))

  (define-record code-block
      make-code-block code-block?
      (code-block-code machine-code))


;; Definition eines  generellen Blocks von Bedingungen

;; Definition der instruction keywords für Bedingungen

(: is-where? (any -> boolean))
(define is-where?
  (lambda (term)
  (and (cons? term)
       (equal? 'where-cond (first term)))))

(define is-where (signature (predicate is-where?)))

(: is? (any -> boolean))
(define is?
  (lambda (term)
  (and (cons? term)
       (equal? 'is? (first term)))))

(define is (signature (predicate is?)))


;; Definition für den Ausstieg aus where-cond
(define-record  break
  make-break break?)

;; Definition einer einzelnen enthltenen Bedingung
(define-record single-cond
  make-single-cond single-cond?
  (single-cond-what machine-code)
  (single-cond-code machine-code))

;; Definition des Bedingungs-Blocks
(define-record conditions
  make-conditions conditions?
  (conditions-conds (list-of single-cond))
 )
;; define record for begin


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
        (char?  term)
        (byte?  term)
        (string? term)
        (alist? term)
        (proc-fun? term)
        (number? term)
        (integer? term)
        )))
        


;; Base Signatur
(define base (signature (predicate base?)))
(define term
  (signature
   (mixed var-symbol
          definition
          fun-application
          where-condition
          application
          abstraction
          more-abstraction
          primitive-application
          is-where
          is
          heap-allocator
          heap-getter
          heap-assignment
          base)))


;; Funktion zur realen Applikation von Primitives
(define apply-primitive
  (lambda (primitive args)
    (begin
 
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
      ))))





; Prädikat für reguläre Applikationen
(: application? (any -> boolean))
(define application?
  (lambda (term)
    (and (cons? term)         
         (not (equal? 'lambda (first term)))
         (not (equal? 'lfn (first term)))       
         (not (equal? 'define (first term)))
         (not (primitive? (first term)))
         )))

;;hier muss geprüft werden ob man das tatsächlich braucht
;;======================================
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
;;======================================

(define application (signature (predicate application?)))


; Prädikat für Abstraktionen
(: definition? (any -> boolean))
(define definition? (lambda (term)
                      (equal?  term 'define) ))

(define definition (signature (predicate definition?)))

;; ======================= DATENTYP DEFINITIONEN (TYPED LANGUAGE) ===============

;; Hier die Prädikate um abzufragen mit welchem Typ wir ees zu tun haben
(define-record alist
  make-alist alist?
  (alist-value base-list-type))

(: alist-def? (any -> boolean))
(define alist-def?
    (lambda (term)
    (and (cons? term)
         (equal? 'alist (first term))
          )))
  (define base-list-type (signature (list-of base?)))
 (define alist-def (signature (predicate alist-def?)))

(define-record prim-type
  make-prim-type prim-type?
  (prim-type-type natural)
  (prim-type-pred ask-type))

(define ask-type (signature (mixed alist-def is-boolean is-integer)))
(: is-boolean? (any -> boolean))

(define is-boolean?
  (lambda (term)
    ((and (cons? term)
          (equal? 'boolean? (first term))))))


(define is-boolean (signature (predicate is-boolean?)))

(: is-integer? (any -> boolean))

(define is-integer?
  (lambda (term)
    ((and (cons? term)
          (equal? 'integer? (first term))))))


(define is-integer (signature (predicate is-integer?)))

(: is-number? (any -> boolean))

(define is-number?
  (lambda (term)
    ((and (cons? term)
          (equal? 'number? (first term))))))

(define is-number (signature (predicate is-number?)))

(: is-string? (any -> boolean))

(define is-string?
  (lambda (term)
    ((and (cons? term)
          (equal? 'string? (first term))))))

(define is-string (signature (predicate is-string?)))

(: is-string? (any -> boolean))

(define is-char?
  (lambda (term)
    ((and (cons? term)
          (equal? 'char? (first term))))))

(define is-char (signature (predicate is-char?)))

(: is-byte? (any -> boolean))

(define is-byte?
  (lambda (term)
    ((and (cons? term)
          (equal? 'byte? (first term))))))

(define is-byte (signature (predicate is-byte?)))

(: is-proc-fun? (any -> boolean))

(define is-proc-fun?
  (lambda (term)
    ((and (cons? term)
          (equal? 'proc-fun? (first term))))))

(define is-proc-fun (signature (predicate is-proc-fun?)))



;; hier die Definitionen zur Typ-Deklaration statische Typisierung

(define-record data-type-decl
  make-data-type-decl data-type-decl?
  (data-type-decl-type-id natural)
  (datatype-decl-type-name string)
  (data-type-decl-len-var boolean)
  (data-type-decl-length natural)
  )



;; ======================= DATATYPE DEFINITIONS (TYPED LANG) ===============


; Prädikat für Abstraktionen
(: abstraction? (any -> boolean))
(define abstraction?
  (lambda (term)
    (and (cons? term)
         (equal? 'lambda (first term))
         )))

; Prädikat für Abstraktionen
(: more-abstraction? (any -> boolean))
(define more-abstraction?
  (lambda (term)
    (and (cons? term)
         (equal? 'fn (first term))
         )))

(define abstraction (signature (predicate abstraction?)))

(define more-abstraction (signature (predicate more-abstraction?)))

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
         (equal? (first term) 'apply-fun)
         )))

(define fun-application (signature (predicate fun-application?)))

; Prädikat für where Bedingungen
(: where-condition? (any -> boolean))
(define where-condition?
  (lambda (term)
    (and (cons? term) 
         (equal? (first term) 'cond-branch)
         )))

(define where-condition (signature (predicate  where-condition?)))



(define primitive-application (signature (predicate primitive-application?)))

;;Record für einen abstrakten Syntax-Baum für spätere Benutzung
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
    (make-stack-element type base? val)
    ))


(: the-empty-environment environment)
(define the-empty-environment empty)

; eine Umgebung um eine Bindung erweitern
(: extend-environment (environment symbol var-value -> environment))

;; Bindung zur Umgebung zufügen
(define  extend-environment
  (lambda (env var-symbol var-value)   
    (cons (make-binding var-symbol var-value)
          
          (remove-environment-binding env var-symbol)  )))

;; Hilfsfunktion für obiges
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

;; Lookup einr Bindung in der aktuellen Umgebung
(: lookup-act-environment (environment symbol -> var-value))

(define lookup-act-environment
  (lambda (environment variable)
    (cond
      ((empty? environment) empty)
      ((cons? environment)
       (if (equal? variable (binding-variable (first environment)))
           (binding-value (first environment))
           (lookup-act-environment (rest environment) variable))))))

;;Lookup einer Bindung -> Reihenfolge
;;  - Aktuelle Umgebung
;;  - Den Generationen nach geordnet von innen nach außen werden die in den Frames (Einheit auf dem Dump)
;; abgespeicherten Umgebungen durclaufen bis wir fündig werden oder eben nicht
;; Somit stellen wir damit eine lexikale Art der Bindung dar 

(define lookup-environment
  (lambda (environment dump variable)
    (let* ((act-val (lookup-act-environment environment variable)))
      (cond ((not (empty? act-val)) act-val)
            (else  (env-lookup-helper dump variable)
                   )))))

;; Hilfsfunktion für Lookup
(define env-lookup-helper (lambda (dump variable)
                            (let* ([env (frame-environment (first dump))]
                                   [binding (lookup-act-environment env variable)])                            
                                  (if (not (empty? binding))
                                      binding
                                      (if (empty? (rest dump))
                                          empty
                                          (env-lookup-helper (rest dump) variable)
                                      )                            
                                  ))))


;; Lookup einr Bindung in der aktuellen Umgebung
(: lookup-heap-stor (heap symbol -> var-value))

(define lookup-heap-stor
  (lambda (heap-instance-rec variable)
    (let ([heap-instance (heap-storage heap-instance-rec)])
    (cond
      ((empty? heap-instance) empty)
      ((cons? heap-instance)
       (if (equal? variable (heap-cell-variable (first heap-instance)))
           (heap-cell-init-value (first heap-instance))
           (lookup-heap-stor (rest heap-instance) variable)))))))

; eine Umgebung um eine Bindung erweitern
(: extend-heap-stor (heap symbol var-value -> heap))

;; Bindung zur Umgebung zufügen
(define  extend-heap-stor
  (lambda (heap-inst-rec var-symbol var-value)
    (let ([heap-inst (heap-storage heap-inst-rec)])
      
    (make-heap (cons (make-heap-cell var-symbol var-value)      
          (remove-heap-stor-cell heap-inst  var-symbol)))
      )))

;; Hilfsfunktion für obiges
(: remove-heap-stor-cell ((list-of heap-cell) var-symbol ->  (list-of heap-cell)))

(define remove-heap-stor-cell
  (lambda (heap-instance variable)
    (cond
      ((empty? heap-instance) empty)
      ((cons? heap-instance)
       (if (equal? variable (heap-cell-variable (first heap-instance)))
           (rest heap-instance)
           (cons (first heap-instance)
                 (remove-heap-stor-cell (rest heap-instance) variable)))))))


;; symbol? unter Ausschluss der "Schlüsselworte"
(: var-symbol? (any -> boolean))
(define var-symbol (signature (predicate var-symbol?)))
(define var-symbol?
  (lambda (term)
    (let ([token term])
      (and (symbol? token)
           (not (equal? token 'define))
           (not (equal? token 'lambda))
               (not (equal? token 'fn))
           (not (equal? token 'app-fun))
           (not (primitive? token))
           (not (equal? token 'cond-branch))
           (not (base? token)) )
      )))
  
