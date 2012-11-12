;;; ecukes-setup.el --- Common setup for drivers

(eval-when-compile
  (require 'cl))
(require 's)
(require 'dash)
(require 'ansi)
(require 'ecukes-steps)
(require 'ecukes-hooks)
(require 'ecukes-project)
(require 'ecukes-template)

(defvar ecukes-message-log nil
  "List of messages to `message'.")

(defadvice message (after ecukes-log-messages-to-buffer activate)
  (when ad-return-value
    (add-to-list 'ecukes-message-log ad-return-value t)))

(defun ecukes-quit (&optional exit-code)
  "Quit Emacs with EXIT-CODE and write to file if in graphical mode."
  (or exit-code (setq exit-code 1))
  (let ((ecukes-outfile (getenv "ECUKES_OUTFILE")))
    (when ecukes-outfile
      (with-temp-buffer
        (insert (s-join "\n" ecukes-message-log))
        (write-file ecukes-outfile nil))))
  (kill-emacs exit-code))

(defun usage ()
  "Show usage information and quit."
  (message
   (ecukes-template-get 'usage))
  (ecukes-quit))

(defun ecukes-setup ()
  "Validate and load."
  (ecukes-setup-help)
  (ecukes-setup-features-dir-exist)
  (ecukes-setup-load))

(defun ecukes-setup-help ()
  "Print usage and quit if `argv' contains '-h' or '--help'."
  (when (or (-contains? argv "-h") (-contains? argv "--help"))
    (usage)))

(defun ecukes-setup-features-dir-exist ()
  "Print usage and quit if there's no features directory."
  (unless (file-directory-p (ecukes-project-features-path))
    (message
     (ansi-red "Missing `features` directory."))
    (usage)))

(defun ecukes-setup-load ()
  "Load support and step definitions."
  (ecukes-setup-load-support)
  (ecukes-setup-load-step-definitions))

(defun ecukes-setup-load-support ()
  "Load project support files."
  (let* ((env-file (expand-file-name "env.el" (ecukes-project-support-path)))
         (support-files
          (-reject
           (lambda (support-file)
             (s-equals? support-file env-file))
           (directory-files (ecukes-project-support-path) t "\\.el$"))))
    (load env-file nil t)
    (-map
     (lambda (support-file)
       (load support-file nil t))
     support-files)))

(defun ecukes-setup-load-step-definitions ()
  "Load project step definition files."
  (let ((step-definition-files (directory-files (ecukes-project-step-definitions-path) t "-steps\\.el$")))
    (-map
     (lambda (step-definition-file)
       (load step-definition-file nil t))
     step-definition-files)))


(provide 'ecukes-setup)