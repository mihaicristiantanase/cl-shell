;;;; shell.lisp

(in-package #:shell)

(defun run (has-output &rest cmd-parts)
  (let* ((parts (mapcar #'convert-to-string cmd-parts))
         (cmd (uiop/launch-program:escape-sh-command parts)))
    (format t "~&shell$ ~A" cmd)
    (let* ((shell-output
             (with-output-to-string (s)
               (sb-ext:run-program "/bin/bash" (list "-c" cmd)
                                   :input nil
                                   :output (when has-output s))
               s))
           (lines (uiop/utility:split-string shell-output :separator '(#\Newline))))
      (remove "" lines :test #'string=))))

(defun convert-to-string (var)
  (handler-case (or (check-type var string) var)
    (error (_)
      (declare (ignore _))
      (format nil "~a" var))))
