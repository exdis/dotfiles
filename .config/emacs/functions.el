;; --- File path utilities ---

(defun copy-relative-file-path ()
  "Copy the current buffer's file path relative to the project root to the clipboard."
  (interactive)
  (let ((path (file-relative-name (buffer-file-name) default-directory)))
    (kill-new path)
    (message "Copied: %s" path)))

(defun copy-absolute-file-path ()
  "Copy the current buffer's file absolute path."
  (interactive)
  (let ((path (buffer-file-name)))
    (kill-new path)
    (message "Copied: %s" path)))

;; --- Centaur tabs ---

(defun my/centaur-tabs-buffer-groups ()
  "Organize tabs into two groups: user files and system/emacs buffers."
  (list
   (cond
    ((string-prefix-p "*" (buffer-name)) "System")
    ((derived-mode-p 'special-mode 'compilation-mode) "System")
    (t "Files"))))

;; --- Flymake / ESLint ---

(defun my/add-node-modules-path ()
  "Add node_modules/.bin to exec-path for the current buffer."
  (let ((root (locate-dominating-file default-directory "node_modules")))
    (when root
      (make-local-variable 'exec-path)
      (add-to-list 'exec-path (expand-file-name "node_modules/.bin" root)))))

(defun my/flymake-eslint-after-eglot ()
  "Add eslint backend after eglot has set up flymake."
  (when (and (bound-and-true-p eglot--managed-mode)
             (derived-mode-p 'js-ts-mode 'typescript-ts-mode 'tsx-ts-mode))
    (my/add-node-modules-path)
    (flymake-eslint-enable)))

(defun my/disable-flymake-eldoc ()
  "Remove flymake from eldoc so diagnostics only show in sideline."
  (setq-local eldoc-documentation-functions
              (remove #'flymake-eldoc-function eldoc-documentation-functions)))

;; --- Corfu ---

(defun my/apply-frame-settings (&optional frame)
  "Apply frame-specific settings based on whether FRAME is graphical."
  (with-selected-frame (or frame (selected-frame))
    (if (display-graphic-p)
        (progn
          ;; GUI: enable centaur-tabs bar, regenerate XPM
          (setq centaur-tabs-set-bar 'left)
          (setq centaur-tabs-active-bar
                (centaur-tabs--make-xpm 'centaur-tabs-active-bar-face
                                        2 centaur-tabs-bar-height))
          ;; GUI: disable corfu-terminal
          (corfu-terminal-mode -1))
      ;; Terminal: no tab bar, enable corfu-terminal
      (setq centaur-tabs-set-bar nil)
      (corfu-terminal-mode 1))))

;; --- Editorconfig ---

(defun my/editorconfig-set-evil-shift-width (props)
  "Sync evil-shift-width with editorconfig indent_size."
  (let ((width (gethash 'indent_size props)))
    (when width
      (setq-local evil-shift-width (string-to-number width)))))

;; --- Perspective ---

(defun my/persp-centaur-tabs-buffer-list ()
  "Return buffer list scoped to current perspective."
  (if (bound-and-true-p persp-mode)
      (persp-current-buffers* t)
    (centaur-tabs-buffer-list)))
(defun my/project-persp-switch ()
  "Switch to a perspective named after the current project."
  (let ((project-name (project-name (project-current))))
    (when project-name
      (persp-switch project-name))))
