;;; cnav --- Contextual navigation -*- lexical-binding: t; -*-

;;; Commentary:

;; Navigate contextually-salient places (loci) in the
;; buffer.  Typically, several minor modes will require user attention
;; at various points in the buffer.  This package offers a single
;; function to navigate all such places with one interface:
;; `cnav-next'.  The salient loci are defined by `cnav-loci'.

;;; Code:
(require 'dash)
(require 's)
(require 'thingatpt)

(declare-function flymake--overlays (&key beg end filter compare key))
(declare-function flymake-goto-next-error (&optional n filter interactive))
(declare-function flymake-diagnostic-type (diagnostic))

(defun cnav-flymake-loci ()
  "Identify all flymake loci, regardless of severity."
  (when (and (bound-and-true-p flymake-mode)
             (flymake--overlays))
    (lambda (n)
      (flymake-goto-next-error n nil t))))

(defun cnav-flymake-loci-severity (severities)
  "Identify flymake loci of any given SEVERITIES."
  (when (and (bound-and-true-p flymake-mode)
             (--some (-some (lambda (s) (eq (flymake-diagnostic-type it) s)) severities)
                     (flymake-diagnostics)))
    (lambda (n)
      (flymake-goto-next-error n severities t))))

(defun cnav-flymake-warning-loci () "Identify flymake warning loci." (cnav-flymake-loci-severity '(:warning eglot-warning)))
(defun cnav-flymake-error-loci () "Identify flymake error loci." (cnav-flymake-loci-severity '(:error eglot-error)))
(defun cnav-flymake-note-loci () "Identify flymake note loci." (cnav-flymake-loci-severity '(:note eglot-note)))

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

(defun cnav-mc-next (n)
  (cond
   ((> n 0)
    (mc/cycle-forward)
    (cnav-mc-next (1- n)))
   
   ((< n 0)
    (mc/cycle-backward)
    (cnav-mc-next (1+ n)))))

(defun cnav-cursor-loci ()
  "Identify cursor loci."
  (when (and (bound-and-true-p multiple-cursors-mode)
             (> (mc/num-cursors) 1))
    'cnav-mc-next))

(defcustom cnav-loci
  '(cnav-cursor-loci
    cnav-smerge-loci
    cnav-flymake-error-loci
    cnav-flymake-warning-loci
    cnav-flymake-note-loci
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
  "Go to Nth next contextually salient locus."
  (interactive "p")
  ;; (message "cnav-next: %s" n)
  (if-let ((fun (--some (funcall it) cnav-loci)))
      (funcall fun n)
    (error "No contextually salient locus")))


(defun cnav-prev (&optional n)
  "Go to Nth previous contextually salient locus."
  (interactive "P")
  (cnav-next (- (or n 1))))
  
(provide 'cnav)
;;; cnav.el ends here
