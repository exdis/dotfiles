;; --- File path utilities ---

(defun my/copy-relative-file-path ()
  "Copy the current buffer's file path relative to the project root to the clipboard."
  (interactive)
  (let* ((root (or (when-let ((proj (project-current)))
                     (project-root proj))
                   default-directory))
         (path (file-relative-name (buffer-file-name) root)))
    (kill-new path)
    (message "Copied: %s" path)))

(defun my/copy-absolute-file-path ()
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

;; --- Frame settings ---

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

(defun my/persp-refresh-tabs ()
  "Refresh centaur-tabs groups after perspective switch."
  (centaur-tabs-buffer-update-groups))

(defvar my/persp--saved-hash nil
  "Saved perspective hash for daemon frame persistence.")

(defvar my/persp--saved-curr-name nil
  "Saved current perspective name for daemon frame persistence.")

(defun my/persp-before-delete-frame (frame)
  "Save perspectives from FRAME before it is deleted."
  (when (and (daemonp)
             (bound-and-true-p persp-mode)
             (frame-parameter frame 'persp--hash)
             (> (hash-table-count (frame-parameter frame 'persp--hash)) 0))
    (with-selected-frame frame
      (persp-save)
      (setq my/persp--saved-hash (copy-hash-table (perspectives-hash frame)))
      (setq my/persp--saved-curr-name (persp-current-name)))))

(defun my/persp-after-make-frame ()
  "Share or restore perspectives for new client frame."
  (when (and (daemonp) (bound-and-true-p persp-mode))
    (let ((source-hash
           (or
            ;; First: share from a live client frame
            (cl-some (lambda (f)
                       (and (not (eq f (selected-frame)))
                            (frame-parameter f 'client)
                            (let ((h (frame-parameter f 'persp--hash)))
                              (and h (> (hash-table-count h) 0) h))))
                     (frame-list))
            ;; Second: restore from saved hash
            (and my/persp--saved-hash
                 (> (hash-table-count my/persp--saved-hash) 0)
                 my/persp--saved-hash))))
      (when source-hash
        (set-frame-parameter nil 'persp--hash source-hash)
        (let* ((target-name (or my/persp--saved-curr-name
                                persp-initial-frame-name))
               (target-persp (gethash target-name source-hash)))
          (when target-persp
            (persp-activate target-persp)))
        (persp-update-modestring)
        (setq my/persp--saved-hash nil)
        (setq my/persp--saved-curr-name nil)))))
