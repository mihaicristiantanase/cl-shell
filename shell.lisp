;;;; shell.lisp

(in-package #:shell)

(defun run (has-output &rest cmd-parts)
  (let* ((cmd (uiop/launch-program:escape-sh-command cmd-parts)))
    (format t "~&shell$ ~A" cmd)
    (let* ((shell-output
             (with-output-to-string (s)
               (sb-ext:run-program "/bin/bash" (list "-c" cmd)
                                   :input nil
                                   :output (when has-output s))
               s))
           (lines (uiop/utility:split-string shell-output :separator '(#\Newline))))
      (remove "" lines :test #'string=))))
