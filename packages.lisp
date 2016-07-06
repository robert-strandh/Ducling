(cl:in-package #:common-lisp-user)

(defpackage ducling
  (:use #:common-lisp)
  (:shadow #:map)
  (:export
   #:map
   #:add-map
   #:add-object
   #:object
   #:make-initial-state
   #:advance
   #:advance-in-map
   #:advance-with-entry))
