;;; dissociate.lisp --- scramble text amusingly for Emacs

;; Copyright (C) 1985, 2002, 2003, 2004, 2005,
;;   2006 Free Software Foundation, Inc.

;; Maintainer: FSF
;; Keywords: games

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; The single entry point, `dissociated-press', applies a travesty
;; generator to the current buffer.  The results can be quite amusing.

;;; Code:

(in-package "LICE")

;;;###autoload
(defcommand dissociated-press ((&optional arg)
                               :raw-prefix)
  "Dissociate the text of the current buffer.
Output goes in buffer named *Dissociation*,
which is redisplayed each time text is added to it.
Every so often the user must say whether to continue.
If ARG is positive, require ARG chars of continuity.
If ARG is negative, require -ARG words of continuity.
Default is 2."
  (setq arg (if arg (prefix-numeric-value arg) 2))
  (let* ((inbuf (current-buffer))
	 (outbuf (get-buffer-create "*Dissociation*"))
	 (move-function (if (> arg 0) 'forward-char 'forward-word))
	 (move-amount (if (> arg 0) arg (- arg)))
	 (search-function (if (> arg 0) 'search-forward 'word-search-forward))
	 (last-query-point 0))
    (if (= (point-max) (point-min))
	(error "The buffer contains no text to start from"))
    (switch-to-buffer outbuf)
    (erase-buffer)
    (while
      (save-excursion
	(goto-char last-query-point)
	(vertical-motion (- (window-height) 4))
	(or (= (point) (point-max))
	    (and (progn (goto-char (point-max))
			(y-or-n-p "Continue dissociation? "))
		 (progn
		   (message "")
		   (recenter 1)
		   (setq last-query-point (point-max))
		   t))))
      (let (start end)
	(save-excursion
	 (set-buffer inbuf)
	 (setq start (point))
	 (if (eq move-function 'forward-char)
	     (progn
	       (setq end (+ start (+ move-amount (random 16))))
	       (if (> end (point-max))
		   (setq end (+ 1 move-amount (random 16))))
	       (goto-char end))
	   (funcall move-function
		    (+ move-amount (random 16))))
	 (setq end (point)))
	(let ((opoint (point)))
	  (insert-buffer-substring inbuf start end)
	  (save-excursion
	   (goto-char opoint)
	   (end-of-line)
	   (and (> (current-column) *fill-column*)
		(do-auto-fill)))))
      (save-excursion
       (set-buffer inbuf)
       (if (eobp)
	   (goto-char (point-min))
	 (let ((overlap
		(buffer-substring (prog1 (point)
					 (funcall move-function
						  (- move-amount)))
				  (point))))
	   (goto-char (1+ (random (1- (point-max)))))
	   (or (funcall search-function overlap :error nil)
	       (let ((opoint (point)))
		 (goto-char 1)
		 (funcall search-function overlap :bound opoint :error nil))))))
      (sit-for 0))))

(provide 'dissociate)

;;; arch-tag: 90d197d1-409b-45c5-a0b5-fbfb2e06334f
;;; dissociate.el ends here
