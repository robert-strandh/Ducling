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

(defclass entry ()
  ((%value :initarg :value :reader value)))

(defclass map-entry (entry) ())

(defclass object-entry (entry) ())

(defgeneric add-map (map-to-add into-map key))

(defmethod add-map ((map-to-add map) (into-map alist-map) key)
  (with-accessors ((contents contents) (test test)) into-map
    (let ((existing-cell (assoc key contents :test test))
	  (entry (make-instance 'map-entry :value map-to-add)))
      (if (null existing-cell)
	  (push (cons key entry) contents)
	  (setf (cdr existing-cell) entry))))
  map-to-add)

(defmethod add-map ((map-to-add map) (into-map hash-table-map) key)
  (setf (gethash key (contents into-map))
	(make-instance 'map-entry :value map-to-add))
  map-to-add)

(defgeneric add-object (object into-map key))

(defmethod add-object (object (into-map alist-map) key)
  (with-accessors ((contents contents) (test test)) into-map
    (let ((existing-cell (assoc key contents :test test))
	  (entry (make-instance 'object-entry :value object)))
      (if (null existing-cell)
	  (push (cons key entry) contents)
	  (setf (cdr existing-cell) entry))))
  object)
