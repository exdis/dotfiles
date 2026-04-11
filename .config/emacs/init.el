;; Load packages config
(load (expand-file-name "packages" user-emacs-directory))

;; Load functions
(load (expand-file-name "functions" user-emacs-directory))

;; Load keybindings
(load (expand-file-name "keybindings" user-emacs-directory))

;; Relative line numbers
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

;; Fonts
(when (display-graphic-p)
  (set-face-attribute 'default nil
		      :family "FiraCode Nerd Font"
		      :height 120))

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
 '(centaur-tabs-active-bar-face    ((t (:background "#FFBC5D"))))
 '(centaur-tabs-default            ((t (:background "#f0f0f0" :foreground "#666"))))
 '(centaur-tabs-selected           ((t (:background "#f5e6cc" :foreground "#333" :weight bold))))
 '(centaur-tabs-unselected         ((t (:background "#e8e8e8" :foreground "#888"))))
 '(centaur-tabs-selected-modified  ((t (:inherit centaur-tabs-selected :slant italic))))
 '(centaur-tabs-unselected-modified ((t (:inherit centaur-tabs-unselected :slant italic)))))
(telephone-line-mode 1)

;; Corfu
(custom-set-faces
 '(corfu-default ((t (:background "#e8e8e8"))))
 '(corfu-current ((t (:background "#c0c0c0" :foreground "#333")))))

;; FlyMake
(custom-set-faces
 '(flymake-error ((t (:underline (:style line :color "#d4a0a0")))))
 '(flymake-warning ((t (:underline (:style line :color "#d4b99a")))))
 '(flymake-note ((t (:underline (:style line :color "#b5c9a8")))))
 '(flymake-popon ((t (:background "#e8e8e8" :foreground "#333")))))
(setq flymake-popon-diagnostic-formatter
      #'my/flymake-popon-format-diagnostic)
