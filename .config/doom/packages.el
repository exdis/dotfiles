;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; ============================================================================
;; Extra packages beyond what Doom modules provide
;; ============================================================================

;; Tmux-aware window navigation (like vim-tmux-navigator)
(package! tmux-pane)

;; Gleam language support (tree-sitter based major mode)
(package! gleam-ts-mode
  :recipe (:host github :repo "gleam-lang/gleam-mode"
           :files ("gleam-ts-mode.el")))

;; Auto-install and manage tree-sitter grammars
(package! treesit-auto)