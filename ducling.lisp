(cl:in-package #:ducling)

;;; This protocol class is the base class for all maps.
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

(defmethod add-object (object (into-map hash-table-map) key)
  (setf (gethash key (contents into-map))
	(make-instance 'object-entry :value object))
  object)

(defclass state ()
  ((%path :initarg :path :reader path)))

(defclass internal-state (state)
  ((%map :initarg :map :reader map)))

(defclass final-state (state)
  ((%object :initarg :object :reader object)))

(defclass error-state (state)
  ())

(defun make-initial-state (map)
  (make-instance 'internal-state
    :path '()
    :map map))

(defgeneric advance (internal-state key))

(defmethod advance ((state state) key)
  (make-instance 'error-state
    :path (append (path state) (list key))))

(defmethod advance ((state internal-state) key)
  (advance-in-map (map state) key (path state)))

(defgeneric advance-in-map (map key path))

(defmethod advance-in-map ((map alist-map) key path)
  (let* ((cell (assoc key (contents map) :test (test map)))
	 (entry (cdr cell))
	 (new-path (append path (list key))))
    (advance-with-entry entry new-path)))

(defmethod advance-in-map ((map hash-table-map) key path)
  (let ((entry (gethash key (contents map)))
	(new-path (append path (list key))))
    (advance-with-entry entry new-path)))

(defgeneric advance-with-entry (entry path))

(defmethod advance-with-entry ((entry map-entry) path)
  (make-instance 'internal-state
    :map (value entry)
    :path path))

(defmethod advance-with-entry ((entry object-entry) path)
  (make-instance 'final-state
    :object (value entry)
    :path path))

(defgeneric possible-completions (state))

(defmethod possible-completions ((state error-state))
  '())

(defmethod possible-completions ((state final-state))
  '())

(defgeneric possible-completions-in-map (map))

(defmethod possible-completions-in-map ((map hash-table-map))
  (loop for key being each hash-key of (contents map)
	collect key))

(defmethod possible-completions-in-map ((map alist-map))
  (mapcar #'car (contents map)))

(defmethod possible-completions ((state internal-state))
  (possible-completions-in-map (map state)))
