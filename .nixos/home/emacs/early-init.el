;; Window bar
(add-to-list 'default-frame-alist '(undecorated . t))

;; Disable menu bar, tool bar, scroll bar — set as frame parameters so
;; emacsclient-created frames inherit them too (mode toggles below alone
;; don't always propagate to client frames).
(add-to-list 'default-frame-alist '(menu-bar-lines . 0))
(add-to-list 'default-frame-alist '(tool-bar-lines . 0))
(add-to-list 'default-frame-alist '(vertical-scroll-bars))
(add-to-list 'default-frame-alist '(horizontal-scroll-bars))

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

;; Disable menu bar, tool bar, scroll bar (also globally, for safety)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)

;; emacsclient -t (TTY) frames don't always honor default-frame-alist for
;; menu-bar-lines. Force it off in every new frame, GUI or TTY.
(defun my/disable-frame-chrome (frame)
  (with-selected-frame frame
    (set-frame-parameter frame 'menu-bar-lines 0)
    (set-frame-parameter frame 'tool-bar-lines 0)
    (when (display-graphic-p frame)
      (set-frame-parameter frame 'vertical-scroll-bars nil)
      (set-frame-parameter frame 'horizontal-scroll-bars nil))))
(add-hook 'after-make-frame-functions #'my/disable-frame-chrome)
