;; Set up packages reositories
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(use-package alabaster-themes
  :ensure t
  :config
  (load-theme 'alabaster-themes-light t))

(use-package evil
  :ensure t
  :init
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :ensure t
  :after evil
  :config
  (evil-collection-init '(neotree)))

(use-package general
  :ensure t
  :config
  (general-create-definer my-leader-def
			  :states '(normal visual motion emacs)
			  :keymaps 'override
			  :prefix "SPC"))

(use-package which-key
  :ensure t
  :config
  (which-key-mode))

(use-package nerd-icons
  :ensure t)

(use-package centaur-tabs
  :ensure t
  :after (alabaster-themes nerd-icons)
  :config
  (setq centaur-tabs-set-icons t)
  (setq centaur-tabs-icon-type 'nerd-icons)
  (setq centaur-tabs-set-modified-marker t)
  (setq centaur-tabs-modified-marker "●")
  (centaur-tabs-mode 1)
  (custom-set-faces
   '(centaur-tabs-default            ((t (:inherit header-line))))
   '(centaur-tabs-selected           ((t (:inherit header-line :weight bold))))
   '(centaur-tabs-unselected         ((t (:inherit mode-line-inactive))))
   '(centaur-tabs-selected-modified  ((t (:inherit centaur-tabs-selected :slant italic))))
   '(centaur-tabs-unselected-modified ((t (:inherit centaur-tabs-unselected :slant italic)))))
  (centaur-tabs-headline-match))

(use-package xclip
  :ensure t
  :after evil
  :config
  (when (and (getenv "WAYLAND_DISPLAY") (executable-find "wl-copy"))
    (setq xclip-method 'wl-copy)
    (setq xclip-program "wl-copy"))
  (xclip-mode 1))

(use-package neotree
  :ensure t
  :after nerd-icons
  :config
  (setq neo-theme 'nerd-icons)
  (setq neo-smart-open t)
  (setq neo-window-width 30))
