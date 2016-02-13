;;; py-feed-baidu.el --- an Emacs Pinyin Translator use baidu olime

;; This is free and unencumbered software released into the public domain.

;; Author: Yu Zhao <zyzy5730@hotmail.com>
;; URL: https://github.com/cmal/emacs-translate-chinese-pinyin-string-use-baidu-olime

;; NEEDS AN INTERNET CONNECTION
;; Usage:
;;  (require 'pinyin-before-point)
;;  (global-set-key (kbd "C-6") 'convert-pinyin-before-point)
;; Test: baidushurufawoxuanzewoxihuan


;; history:
;; 2016-02-14 :
;;   first version, translate full char string using baidu olime,

;;; Code:

(require 'json)

(defun get-baidu-pinyin-json-string (keyboard)
  (interactive)
  (progn (set-buffer
	  (url-retrieve-synchronously
	   (concat
	    "http://olime.baidu.com/py?rn=0&pn=20&py="
	    keyboard)
	   t nil))
	 (forward-line 8)
	 (buffer-substring-no-properties
	  (line-beginning-position)
	  (line-end-position))
	 ))

(defun pinyin-to-vector (string)
  (let* ((json
	  (progn
	    (set-buffer
	     (url-retrieve-synchronously
	      (concat
	       "http://olime.baidu.com/py?rn=0&pn=20&py="
	       string)
	      t nil))
	    (forward-line 8)
	    (buffer-substring-no-properties
	     (line-beginning-position)
	     (line-end-position))))
	 (vector (aref
		  (json-read-from-string
		   (decode-coding-string json 'gbk)) 0)))
    vector))


(defun vector-to-list (vector idx)
  (interactive)
  (let ((i 0) list)
    (while (< i (length vector))
      (setq list
	    (append
	     list
	     (list
	      (aref (aref vector i) idx))))
      (setq i (1+ i)))
    list))

(defun read-tail-pinyin ()
;  (interactive)
  (let ((string
	 (if mark-active
	     (buffer-substring-no-properties
	      (region-beginning) (region-end))
	   (buffer-substring
	    (point)
	    (save-excursion
	      (skip-syntax-backward "w")
	      (point))))))
    (setq idx (string-match "[a-z-]+$" string))
    (substring string idx)))

;;like org-agenda buffer

(defun convert-pinyin-before-point ()
  (interactive)
  (let* (
         (string-before-point (read-tail-pinyin))
	 (last-buffer (current-buffer))
	 (chinese-list (vector-to-list (pinyin-to-vector string-before-point) 0))
	 (breakpoint-list (vector-to-list (pinyin-to-vector string-before-point) 1))
	 (py-length (length string-before-point))
	 (fwidth (frame-width (selected-frame)))
	 (modular (min 3 (max 2 (/ fwidth (+ 4 fwidth)))))
	 c prefixes
	)
      (save-window-excursion
	(delete-other-windows)
	(switch-to-buffer-other-window
	 (generate-new-buffer " *Choices Cloud Pinyin*"))
	(erase-buffer)
	(insert "
请选择：(<SPC>:默认, 非选项任意键:退出不转换)
------------------------------")
	(dotimes (i (length chinese-list))
	  (push (+ i 97) prefixes)
	  (if (eq 0 (mod i modular)) (insert "\n"))
	  (insert
	   (format (concat "%c %-" (number-to-string py-length) "s  ")
		   (+ i 97)
		   (concat
		    (nth i chinese-list)
		    (substring string-before-point
			       (nth i breakpoint-list)))
		   )))
	(setq buffer-read-only t)
	(goto-char (point-min))
	(message "输入对应的字母:")
	(setq c (read-char-exclusive))
	(message (number-to-string c))
	(cond ((eq c 32) (setq c ?a)))
	(message "")
	(delete-window))
      (if (memq c prefixes)
      	  (setq
	   substitution
	   (concat
	    (nth (- c 97) chinese-list)
	    (substring string-before-point
		       (nth (- c 97) breakpoint-list)))))
      (switch-to-buffer last-buffer)
      (delete-backward-char py-length)
      (insert substitution)
      ))

(provide 'pinyin-before-point)
