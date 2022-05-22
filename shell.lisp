;;;; shell.lisp

(in-package #:shell)

;; TODO(mihai): integrate https://github.com/jorams/cl-shellwords to extract words from a command

;; TODO(mihai): handle this case: (sb-ext:run-program "/bin/bash" '("-c" "while true; do date; sleep 1; done") :output "/tmp/a.txt")

(defun run-general (has-output input &rest cmd-parts)
  (let* ((parts (mapcar #'convert-to-string cmd-parts))
         (cmd (uiop/launch-program:escape-sh-command parts)))
    (format t "~&shell$ ~A" cmd)
    (let* ((out (if (eq has-output t) (make-string-output-stream) has-output))
           (proc (sb-ext:run-program "/bin/bash" (list "-c" cmd)
                                     :input input
                                     :output out
                                     :if-output-exists :supersede
                                     :wait (not (eq has-output :stream))))
           (lines (if (is-stream out)
                      (uiop/utility:split-string (get-output-stream-string out)
                                                 :separator '(#\Newline)))))
      (values (remove "" lines :test #'string=)
              proc))))

;; OBS(mihai): backwards compatibility
(defun run (has-output &rest cmd-parts)
  (apply #'run-out has-output cmd-parts))

;; TODO(mihai): pass the parameter here
(defun run-out (&rest cmd-parts)
  (apply #'run-general t nil cmd-parts))

(defun run-in (input &rest cmd-parts)
  (apply #'run-general nil input cmd-parts))

(defun run-in-out (has-output input &rest cmd-parts)
  (apply #'run-general has-output input cmd-parts))
