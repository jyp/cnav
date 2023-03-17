
;;; Commentary:

;;; Code:
(require 'dash)
(require 's)
(require 'thingatpt)


;; TODO: do various flymake levels?

(declare-function flymake--overlays (&key beg end filter compare key))
(declare-function flymake-goto-next-error (&optional n filter interactive))

(defun cnav-flymake-loci ()
  "Identify flymake loci."
  (when (and (bound-and-true-p flymake-mode)
             (flymake--overlays))
    (lambda (n)
      (flymake-goto-next-error n nil t))))

(defun cnav-error-loci ()
  "Default loci."
  'next-error)

(declare-function smerge-find-conflict (&optional limit))

(defun cnav-smerge-loci ()
  "Identify smerge loci."
  (when (and (bound-and-true-p smerge-mode)
             (save-excursion (goto-char (point-min))
                             (smerge-find-conflict (point-max))))
    'smerge-next))

(defcustom cnav-loci
  '(cnav-smerge-loci
    cnav-flymake-loci
    ;; cnav-flymake-info-loci
    ;; cnav-flycheck-loci
    ;; cnav-flyspell-loci ; not very useful because flyspell only looks at the current line anyway
    cnav-error-loci)
  "List of functions to determine contextually meaningful navigation targets.
Each function should take no argument and return either nil to
indicate it found no locus, or a function to go to nearby
locus.  This function takes an integer which is the number of loci
to move."
  :type 'hook
  :group 'cnav)


(defun cnav-next (&optional n)
  "Go to Nth next contextually relevant locus."
  (interactive "p")
  ;; (message "cnav-next: %s" n)
  (if-let ((fun (--some (funcall it) cnav-loci)))
      (funcall fun n)
    (error "No contextually relevant locus")))


(defun cnav-prev (&optional n)
  "Go to Nth previous contextually relevant locus."
  (interactive "P")
  (cnav-next (- (or n 1))))
  
(provide 'cnav)
;;; cnav.el ends here
