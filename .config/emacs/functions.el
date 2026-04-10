(defun copy-relative-file-path ()
  "Copy the current buffer's file path relative to the project root to the clipboard"
  (interactive)
  (let ((path (file-relative-name (buffer-file-name) default-directory)))
    (kill-new path)
    (message "Copied: %s" path)))

(defun copy-absolute-file-path ()
  "Copy the current buffer's file absolute path"
  (interactive)
  (let ((path (buffer-file-name)))
    (kill-new path)
    (message "Copied: %s" path)))
