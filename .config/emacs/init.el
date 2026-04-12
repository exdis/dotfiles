;; Load functions
(load (expand-file-name "functions" user-emacs-directory))

;; Load packages
(load (expand-file-name "packages" user-emacs-directory))

;; Load keybindings
(load (expand-file-name "keybindings" user-emacs-directory))

;; --- Global settings ---

;; Editorconfig
(editorconfig-mode 1)
(add-hook 'editorconfig-after-apply-functions #'my/editorconfig-set-evil-shift-width)

;; Relative line numbers
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

;; Redirect custom-set-variables to a separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;; Backups and auto-save
(setq backup-directory-alist '(("." . "~/.emacs-backup")))
(setq auto-save-file-name-transforms '((".*" "~/.emacs-save/" t)))

;; Trust common dir-locals values
(setq safe-local-variable-values
  '((evil-shift-width . 2)))

;; --- Face customizations ---

(custom-set-faces
 ;; Centaur tabs
 '(centaur-tabs-active-bar-face     ((t (:background "#FFBC5D"))))
 '(centaur-tabs-default             ((t (:background "#f0f0f0" :foreground "#666"))))
 '(centaur-tabs-selected            ((t (:background "#f5e6cc" :foreground "#333" :weight bold))))
 '(centaur-tabs-unselected          ((t (:background "#e8e8e8" :foreground "#888"))))
 '(centaur-tabs-selected-modified   ((t (:inherit centaur-tabs-selected :slant italic))))
 '(centaur-tabs-unselected-modified ((t (:inherit centaur-tabs-unselected :slant italic))))
 ;; Corfu
 '(corfu-default ((t (:background "#e8e8e8"))))
 '(corfu-current ((t (:background "#c0c0c0" :foreground "#333"))))
 ;; Flymake
 '(flymake-error   ((t (:underline (:style line :color "#d4a0a0")))))
 '(flymake-warning ((t (:underline (:style line :color "#d4b99a")))))
 '(flymake-note    ((t (:underline (:style line :color "#b5c9a8")))))
 ;; Sideline flymake
 '(sideline-flymake-error   ((t (:foreground "#AA3731" :slant italic))))
 '(sideline-flymake-warning ((t (:foreground "#CB8927" :slant italic))))
 '(sideline-flymake-note    ((t (:foreground "#448C27" :slant italic))))
 ;; Diff HL
 '(diff-hl-margin-insert ((t (:foreground "#448C27" :inherit nil))))
 '(diff-hl-margin-change ((t (:foreground "#FFBC5D" :inherit nil))))
 '(diff-hl-margin-delete ((t (:foreground "#AA3731" :inherit nil)))))

;; --- Centaur tabs ---
(setq centaur-tabs-set-icons t)
(setq centaur-tabs-icon-type 'nerd-icons)
(setq centaur-tabs-set-modified-marker t)
(setq centaur-tabs-modified-marker "●")
(setq centaur-tabs-buffer-groups-function #'my/centaur-tabs-buffer-groups)
(centaur-tabs-mode 1)
(centaur-tabs-headline-match)

;; --- Frame-specific settings (daemon-compatible) ---
(if (daemonp)
    (add-hook 'server-after-make-frame-hook #'my/apply-frame-settings)
  (my/apply-frame-settings))

;; --- Dashboard ---

(setq dashboard-banner-logo-title "")
(setq dashboard-startup-banner 'logo)
(setq dashboard-center-content t)
(setq dashboard-vertically-center-content t)
(setq dashboard-items '((recents . 8)
                        (projects . 5)))
(setq dashboard-projects-backend 'project-el)
(setq dashboard-display-icons-p t)
(setq dashboard-icon-type 'nerd-icons)
(setq dashboard-set-heading-icons t)
(setq dashboard-set-file-icons t)
(dashboard-setup-startup-hook)

;; --- Clipboard ---

(when (and (getenv "WAYLAND_DISPLAY") (executable-find "wl-copy"))
  (setq xclip-method 'wl-copy)
  (setq xclip-program "wl-copy"))
(xclip-mode 1)

;; --- NeoTree ---

(setq neo-theme 'nerd-icons)
(setq neo-smart-open t)
(setq neo-window-width 30)

;; --- Flymake ---

(setq flymake-margin-indicators-string
      '((error "!!" compilation-error)
        (warning "?" compilation-warning)
        (note "·" compilation-info)))

;; --- Flymake ESLint ---

(setq flymake-eslint-prefer-json-diagnostics t)
(add-hook 'eglot-managed-mode-hook #'my/flymake-eslint-after-eglot)
(add-hook 'eglot-managed-mode-hook #'my/disable-flymake-eldoc 100)

;; --- Telephone line ---

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
(telephone-line-mode 1)

;; --- Eglot ---
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '(gleam-ts-mode . ("gleam" "lsp")))
  (add-to-list 'eglot-server-programs '(nix-ts-mode . ("nixd"))))

;; --- Diff HL ---
(setq diff-hl-margin-symbols-alist
      '((insert . "│")
        (delete . "│")
        (change . "│")
        (unknown . "│")
        (ignored . "│")))
(diff-hl-margin-mode 1)
(global-diff-hl-mode 1)
