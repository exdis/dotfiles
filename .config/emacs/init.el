;; Load packages config
(load (expand-file-name "packages" user-emacs-directory))

;; Load functions
(load (expand-file-name "functions" user-emacs-directory))

;; Load keybindings
(load (expand-file-name "keybindings" user-emacs-directory))

;; Relative line numbers
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

;; Disable menu bar
(menu-bar-mode -1)

;; Redirect custom-set-variables to a separate file to avoid init.el pollution
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;; Backups and auto-save
(setq backup-directory-alist '(("." . "~/.emacs-backup")))
(setq auto-save-file-name-transforms '((".*" "~/.emacs-save/" t)))
