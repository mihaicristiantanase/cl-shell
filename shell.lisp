;;;; shell.lisp

(in-package #:shell)

;; TODO(mihai): integrate https://github.com/jorams/cl-shellwords to extract words from a command

;; TODO(mihai): handle this case: (sb-ext:run-program "/bin/bash" '("-c" "while true; do date; sleep 1; done") :output "/tmp/a.txt")

(defun run-general (output input &rest cmd-parts)
  (let* ((parts (mapcar #'convert-to-string cmd-parts))
         (cmd (uiop/launch-program:escape-sh-command parts)))
    (format t "~&shell$ ~A" cmd)
    (let* ((out (if (eq output t) (make-string-output-stream) output))
           (proc (sb-ext:run-program "/bin/bash" (list "-c" cmd)
                                     :input input
                                     :output out
                                     :if-output-exists :supersede
                                     :wait (not (eq output :stream))))
           (lines (if (is-stream out)
                      (uiop/utility:split-string (get-output-stream-string out)
                                                 :separator '(#\Newline)))))
      (values (remove "" lines :test #'string=)
              proc))))

;; OBS(mihai): backwards compatibility
(defun run (output &rest cmd-parts)
  (apply #'run-out output cmd-parts))

(defun run-out (output &rest cmd-parts)
  (apply #'run-general output nil cmd-parts))

(defun run-in (input &rest cmd-parts)
  (apply #'run-general nil input cmd-parts))

(defun run-in-out (output input &rest cmd-parts)
  (apply #'run-general output input cmd-parts))
