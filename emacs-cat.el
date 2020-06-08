;;; emacs-cat.el --- A simplistic Emacs CAT (Computer Aided Translation) mode  -*- lexical-binding: t; -*-

;; Copyright (C) 2020  Marcin Borkowski

;; Author: Marcin Borkowski <mbork@mbork.pl>
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This is a very simple mode to aid in translations.  As of now, it
;; only supports highlighting the currently translated sentence and
;; easily moving the highlight even without going to another
;; buffer/window.

;;; Code:



(provide 'emacs-cat)
;;; emacs-cat.el ends here

(defface emacs-cat-highlight-face '((t :background "#e7ede7"))
  "Face for highlighting the currently translated sentence.")

(defvar emacs-cat-sentence-overlay nil
  "The overlay to highlight the currently translated sentence.")

(defun emacs-cat-highlight-this-sentence ()
  "Highlight the sentence at point using an overlay."
  (interactive)
  (save-excursion
    (let ((sentence-end (progn (forward-sentence)
			       (point)))
	  (sentence-beginning (progn (backward-sentence)
				     (point))))
      (if (overlayp emacs-cat-sentence-overlay)
	  (move-overlay emacs-cat-sentence-overlay sentence-beginning sentence-end (current-buffer))
	(setq emacs-cat-sentence-overlay
	      (make-overlay sentence-beginning sentence-end))
	(overlay-put emacs-cat-sentence-overlay 'face 'emacs-cat-highlight-face)))))

(defun emacs-cat-highlight-next-sentence ()
  "Move the highlight to the next sentence."
  (interactive)
  (save-excursion
    (set-buffer (overlay-buffer emacs-cat-sentence-overlay))
    (goto-char (overlay-start emacs-cat-sentence-overlay))
    (forward-sentence)
    (emacs-cat-highlight-this-sentence)))

(defun emacs-cat-highlight-previous-sentence ()
  "Move the highlight to the previous sentence."
  (interactive)
  (save-excursion
    (set-buffer (overlay-buffer emacs-cat-sentence-overlay))
    (goto-char (overlay-start emacs-cat-sentence-overlay))
    (backward-sentence)
    (emacs-cat-highlight-this-sentence)))

(defun emacs-cat-disable-sentence-highlighting ()
  "Disable sentence highlighting."
  (interactive)
  (delete-overlay emacs-cat-sentence-overlay))

(setq emacs-cat-basic-map (make-sparse-keymap))

(define-key emacs-cat-basic-map (kbd "p") #'emacs-cat-highlight-previous-sentence)
(define-key emacs-cat-basic-map (kbd "n") #'emacs-cat-highlight-next-sentence)
(define-key emacs-cat-basic-map (kbd ".") #'emacs-cat-highlight-this-sentence)

(easy-mmode-defmap emacs-cat-mode-map
  `((,(kbd "C-c .") . ,emacs-cat-basic-map))
  "Keymap for `emacs-cat-mode'.")

(define-minor-mode emacs-cat-mode
  "Toggle `emacs-cat-mode'."
  :lighter " CAT"
  :keymap emacs-cat-mode-map
  :global t
  (if emacs-cat-mode
      (emacs-cat-highlight-this-sentence)
    (emacs-cat-disable-sentence-highlighting)))
