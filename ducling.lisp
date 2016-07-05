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

(defmethod add-map ((map-to-add map) (into-map alist-map) key)
  (with-accessors ((contents contents) (test test)) into-map
    (let ((existing-entry (assoc key contents :test test)))
      (if (null existing-entry)
	  (push (cons key map-to-add) contents)
	  (setf (cdr existing-entry) map-to-add))))
  map-to-add)
