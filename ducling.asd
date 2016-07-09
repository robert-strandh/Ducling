(cl:in-package #:asdf-user)

(defsystem :ducling
  :description "Library providing a multi-level map."
  :author "Robert Strandh <robert.strandh@gmail.com>"
  :license "FreeBSD, see file LICENSE.text"
  :serial t
  :components
  ((:file "packages")
   (:file "ducling")))
