;; Leader key bindings
(my-leader-def
 "f" '(:ignore t :which-key "file")
 "ff" '(find-file :which-key "find file")
 "fs" '(save-buffer :which-key "save file")
 "b" '(:ignore t :which-key "buffer")
 "bd" '(kill-current-buffer :which-key "kill buffer"))

;; Help keys
(my-leader-def
  "h" '(:ignore t :which-key "help")
  "hk" '(describe-key :which-key "describe key")
  "hf" '(describe-function :which-key "describe function")
  "hv" '(describe-variable :which-key "describe variable"))

;; Split navigation
(define-key evil-normal-state-map (kbd "C-h") 'evil-window-left)
(define-key evil-normal-state-map (kbd "C-j") 'evil-window-down)
(define-key evil-normal-state-map (kbd "C-k") 'evil-window-up)
(define-key evil-normal-state-map (kbd "C-l") 'evil-window-right)

;; Tab navigation
(define-key evil-normal-state-map (kbd "H") 'centaur-tabs-backward)
(define-key evil-normal-state-map (kbd "L") 'centaur-tabs-forward)

;; Copy relative file path
(my-leader-def
  "yy" '(copy-relative-file-path :which-key "copy relative path")
  "yY" '(copy-absolute-file-path :which-key "copy absolute path"))

;; NeoTree
(my-leader-def
  "n" '(neotree-toggle :which-key "file tree"))

;; Search
(my-leader-def
  "/" '(consult-ripgrep :which-key "ripgrep search")
  "SPC" '(consult-fd :which-key "find file"))

;; Enhanced buffer switching
(my-leader-def
  "bb" '(consult-buffer :which-key "switch buffer"))

;; LSP actions
(my-leader-def
  "l" '(:ignore t :which-key "lsp")
  "lr" '(eglot-rename :which-key "rename")
  "la" '(eglot-code-actions :which-key "code actions")
  "lf" '(eglot-format :which-key "format"))

;; Flymake
(my-leader-def
  "d" '(:ignore t :which-key "diagnostics" )
  "dd" '(flymake-show-buffer-diagnostics :which-key "list diagnostics")
  "dn" '(flymake-goto-next-error :which-key "next error")
  "dp" '(flymake-goto-prev-error :which-key "prev error"))
