(cl:in-package #:asdf-user)

(defsystem :ducling
  :serial t
  :components
  ((:file "packages")
   (:file "ducling")))
