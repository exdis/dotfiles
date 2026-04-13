;; Window bar
(add-to-list 'default-frame-alist '(undecorated . t))

;; macOS modifier keys: use Command as Meta, Option as Super
(when (eq system-type 'darwin)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'super))

;; Fonts
(add-to-list 'default-frame-alist '(font . "FiraCode Nerd Font-12"))

;; Startup screen
(setq inhibit-startup-screen t)

;; Disable menu bar, tool bar, scroll bar
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
