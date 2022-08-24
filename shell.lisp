;;;; shell.lisp

(in-package #:shell)

;; TODO(mihai): integrate https://github.com/jorams/cl-shellwords to extract words from a command

;; TODO(mihai): handle this case: (sb-ext:run-program "/bin/bash" '("-c" "while true; do date; sleep 1; done") :output "/tmp/a.txt")

(defparameter *env* nil)

(defun generate-command-from-environment ()
  "Documentation for generate-command-from-environment with parameters "
  (let ((processed-env
          (mapcar #'(lambda (kv)
                      (format nil "~a=~a"
                              (uiop/launch-program:escape-sh-command (list (car kv)))
                              (uiop/launch-program:escape-sh-command (list (cdr kv)))))
                  *env*)))
    (when processed-env (format nil "~{~a~^ ~}" processed-env))))

(defun run-general (output input &rest cmd-parts)
  (let* ((parts (mapcar #'convert-to-string cmd-parts))
         (cmd-env (generate-command-from-environment))
         (cmd (uiop/launch-program:escape-sh-command parts))
         (cmd-full (format nil "~@[~A ~]~A" cmd-env cmd)))
    (format t "~&shell$ ~A" cmd-full)
    (let* ((out (if (eq output t) (make-string-output-stream) output))
           (proc (sb-ext:run-program "/bin/bash" (list "-c" cmd-full)
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
