(cl:in-package #:ducling)

(defclass map () ())
  

(defclass hash-table-map (map)
  ((%contents :initarg :contents :reader contents)))

(defclass alist-map (map)
  ((%test :initarg :test :reader test)
   (%contents :initarg :contents :accessor contents)))

(defmethod initialize-instance :after ((map map) &key (test #'eql))
  (if (member test (list #'eq #'eql #'equal #'equalp
			 'eq 'eql 'equal 'equalp))
      (change-class map 'hash-table-map
		    :contents (make-hash-table :test test))
      (change-class map 'alist-map
		    :contents '()
		    :test test)))

(defgeneric add-map (map-to-add into-map key))
