;;;; shell.asd

(asdf:defsystem #:shell
  :description "Execute shell commands"
  :author "Mihai Cristian Tănase <mihaicristian.tanase@gmail.com>"
  :license  "TODO"
  :version "0.1"
  :serial t
  :components ((:file "package")
               (:file "shell")))
