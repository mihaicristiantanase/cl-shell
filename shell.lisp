;;;; shell.lisp

(in-package #:shell)

;; TODO: integrate https://github.com/jorams/cl-shellwords to extract words from a command

(defun run-general (has-output input &rest cmd-parts)
  (let* ((parts (mapcar #'convert-to-string cmd-parts))
         (cmd (uiop/launch-program:escape-sh-command parts)))
    (format t "~&shell$ ~A" cmd)
    (let* ((shell-output
             (with-output-to-string (s)
               (sb-ext:run-program "/bin/bash" (list "-c" cmd)
                                   :input input
                                   :output (when has-output s))
               s))
           (lines (uiop/utility:split-string shell-output :separator '(#\Newline))))
      (remove "" lines :test #'string=))))

;; OBS(mihai): backwards compatibility
(defun run (has-output &rest cmd-parts)
  (apply #'run-out has-output cmd-parts))

(defun run-out (&rest cmd-parts)
  (apply #'run-general t nil cmd-parts))

(defun run-in (input &rest cmd-parts)
  (apply #'run-general nil input cmd-parts))

(defun run-in-out (has-output input &rest cmd-parts)
  (apply #'run-general has-output input cmd-parts))

(defun convert-to-string (var)
  (handler-case (or (check-type var string) var)
    (error (_)
      (declare (ignore _))
      (format nil "~a" var))))
