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

;; Telephone line colors
(setq telephone-line-primary-left-separator 'telephone-line-cubed-left
      telephone-line-secondary-left-separator 'telephone-line-cubed-hollow-left
      telephone-line-primary-right-separator 'telephone-line-cubed-right
      telephone-line-secondary-right-separator 'telephone-line-cubed-hollow-right)
(setq telephone-line-lhs
      '((evil   . (telephone-line-evil-tag-segment))
        (accent . (telephone-line-buffer-segment))
	(nil    . ())))
(setq telephone-line-rhs
      '((nil    . (telephone-line-major-mode-segment))
        (accent . (telephone-line-airline-position-segment))))
(custom-set-faces
 '(telephone-line-accent-active ((t (:background "#c0c0c0" :foreground "#333"))))
 '(telephone-line-accent-inactive ((t (:background "#e8e8e8" :foreground "#999"))))
 '(telephone-line-evil-normal ((t (:background "#b5c9a8" :foreground "#333"))))
 '(telephone-line-evil-insert ((t (:background "#a3c1d9" :foreground "#333"))))
 '(telephone-line-evil-visual ((t (:background "#c4aed0" :foreground "#333"))))
 '(telephone-line-evil-emacs ((t (:background "#d4b99a" :foreground "#333"))))
 '(telephone-line-evil-replace ((t (:background "#d4a0a0" :foreground "#333")))))
(telephone-line-mode 1)
