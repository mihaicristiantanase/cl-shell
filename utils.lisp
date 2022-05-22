;;;; utils.lisp

(in-package #:shell)

(defun convert-to-string (var)
  (handler-case (or (check-type var string) var)
    (error (_)
      (declare (ignore _))
      (format nil "~a" var))))

(defun is-stream (obj)
  (handler-case (or (check-type obj stream) t)
    (error (_)
      (declare (ignore _))
      nil)))
