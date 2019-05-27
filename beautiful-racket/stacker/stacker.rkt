#lang br/quicklang

; define a reader
(define (read-syntax path port)
  (define src-lines (port->lines port))
  (define src-datums (format-datums '(handle ~a) src-lines))
  (define module-datum `(module stacker-mod "stacker.rkt"
                           ,@src-datums))
  (datum->syntax #f module-datum))
(provide read-syntax)

(define-macro (stacker-module-begin HANDLE-EXPR ...)
  #'(#%module-begin
     HANDLE-EXPR ...
     (display (first stack))))
(provide (rename-out [stacker-module-begin #%module-begin]))

(define (handle [arg #f])
  (cond [(number? arg) (push-stack! arg)]
        [(or (equal? + arg) (equal? * arg))
         (define result (arg (pop-stack!) (pop-stack!)))
         (push-stack! result)]))
(provide handle)
(provide + *)

; Stack for the language

; Initial state of the stack, mutated by push/pop-stack! below
(define stack empty)

(define (pop-stack!)
  (define arg (first stack))
  (set! stack (rest stack))
  arg)
(define (push-stack! arg)
  (set! stack (cons arg stack)))