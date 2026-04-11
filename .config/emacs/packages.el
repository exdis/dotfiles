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

(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  (corfu-auto-prefix 2)
  :config
  (global-corfu-mode))

(use-package corfu-terminal
  :ensure t
  :after corfu
  :config
  (unless (display-graphic-p)
    (corfu-terminal-mode 1)))

(use-package vertico
  :ensure t
  :config
  (vertico-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :ensure t
  :config
  (marginalia-mode))

(use-package eglot
  :hook
  ((typescript-ts-mode js-ts-mode tsx-ts-mode) . eglot-ensure)
  ((c-ts-mode c++-ts-mode) . eglot-ensure)
  (rust-ts-mode . eglot-ensure)
  (zig-mode . eglot-ensure)
  (gleam-ts-mode . eglot-ensure)
  (python-ts-mode . eglot-ensure)
  ((html-mode css-ts-mode) . eglot-ensure))

(use-package consult
  :ensure t)

(use-package treesit-auto
  :ensure t
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package evil-commentary
  :ensure t
  :after evil
  :config
  (evil-commentary-mode))

(use-package telephone-line
  :ensure t)
