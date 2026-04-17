;; Window bar
(add-to-list 'default-frame-alist '(undecorated . t))

;; macOS modifier keys:
;; Left Cmd  -> Super (native mac shortcuts: Cmd+V, Cmd+C, ...)
;; Right Cmd -> Meta  (M-x etc.)
;; Option    -> none  (let kanata layers pass through untouched)
(when (eq system-type 'darwin)
  (setq mac-command-modifier       'super)
  (setq mac-right-command-modifier 'meta)
  (setq mac-option-modifier        'none)
  (setq mac-right-option-modifier  'none))

;; Fonts
(add-to-list 'default-frame-alist '(font . "FiraCode Nerd Font-12"))

;; Startup screen
(setq inhibit-startup-screen t)

;; Disable menu bar, tool bar, scroll bar
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
