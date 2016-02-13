;;; py-feed-baidu.el --- an Emacs Pinyin Translator use baidu olime

;; This is free and unencumbered software released into the public domain.

;; Author: Yu Zhao <zyzy5730@hotmail.com>
;; URL: https://github.com/cmal/emacs-translate-chinese-pinyin-string-use-baidu-olime

;;; Code:

(defun get-baidu-pinyin ()
  (interactive)
  (progn (set-buffer (url-retrieve-synchronously "http://olime.baidu.com/py?rn=0&pn=20&py=shei"))
	 (forward-line 8)
	 (buffer-substring-no-properties (line-beginning-position) (line-end-position))
	 ))
