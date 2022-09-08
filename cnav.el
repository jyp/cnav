
(require 'dash)
(require 's)
(require 'thingatpt)
(require 'cl)

(defun cnav-error-target ()
  (cons 'prev-error 'next-error)
  )


(defcustom cnav-targets
  '(cnav-target-flymake-diagnostics
    ;; cnav-smerge-target
    ;; cnav-flycheck-target
    ;; cnav-flyspell-target
    cnav-error-target
    )
  "List of functions to determine contextually meaningful navigation targets.
Each function should take no argument and return either nil to
indicate it found no target or a list of the form (prev-function next-function)"
  :type 'hook
  :group 'cnav)
