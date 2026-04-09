;;; init.el -*- lexical-binding: t; -*-

;; Doom module selection -- tailored from a Neovim setup with:
;; Telescope, Treesitter, LSP, Flash, vim-surround, vim-commentary,
;; nvim-tree, bufferline, gitsigns, autopairs, lualine, indent-blankline,
;; copilot, neoformat, spectre, neoscroll, tmux-navigator

(doom! :input

       :completion
       (corfu +orderless)  ; code completion (like blink.cmp)
       vertico             ; fuzzy finder (like Telescope)

       :ui
       doom              ; Doom's look and feel
       dashboard         ; startup splash screen
       hl-todo           ; highlight TODO/FIXME/NOTE etc.
       indent-guides     ; highlighted indent columns (like indent-blankline)
       modeline          ; status line (like lualine)
       nav-flash         ; blink cursor line after big motions
       ophints           ; highlight the region an operation acts on
       (popup +defaults) ; tame popup windows
       tabs              ; tab bar (like bufferline)
       treemacs          ; file explorer sidebar (like nvim-tree)
       (vc-gutter +pretty) ; git diff in the fringe (like gitsigns)
       vi-tilde-fringe   ; ~ marks beyond end of buffer
       window-select     ; visually switch windows
       workspaces        ; tab emulation and workspaces
       smooth-scroll     ; smooth scrolling (like neoscroll)

       :editor
       (evil +everywhere); Vim keybindings everywhere -- the whole point!
       file-templates    ; auto-snippets for empty files
       fold              ; code folding
       (format +onsave)  ; auto-format on save (like neoformat)
       multiple-cursors  ; editing in many places at once
       snippets          ; snippet support
       (whitespace +guess +trim) ; whitespace management

       :emacs
       dired             ; file management
       electric          ; smarter electric-indent
       ibuffer           ; interactive buffer management
       tramp             ; remote file editing
       undo              ; persistent undo (like vim undo)
       vc                ; version control integration

       :term
       vterm             ; terminal emulator inside Emacs

       :checkers
       syntax            ; on-the-fly syntax checking (like eslint diagnostics)

       :tools
       editorconfig      ; respect .editorconfig files
       (eval +overlay)   ; run code, see results inline
       lookup            ; jump to definition, references, docs
       (lsp +eglot)      ; LSP support via eglot (built into Emacs 30)
       magit             ; the best git interface in any editor
       tree-sitter       ; better syntax highlighting and code analysis

       :os
       (:if (featurep :system 'macos) macos)
       tty               ; better terminal Emacs experience

       :lang
       (cc +lsp +tree-sitter)              ; C/C++ with clangd
       data                                 ; config/data formats (json, yaml, toml, etc.)
       emacs-lisp                           ; you'll need this for configuring Emacs
       (javascript +lsp +tree-sitter)       ; JS/TS with ts_ls
       markdown                             ; markdown support
       nix                                  ; Nix expression language (you're on NixOS!)
       org                                  ; org-mode
       (python +lsp +tree-sitter)           ; Python with pylsp
       (rust +lsp +tree-sitter)             ; Rust with rust-analyzer
       sh                                   ; shell scripts
       (web +lsp +tree-sitter)              ; HTML/CSS
       (zig +lsp +tree-sitter)              ; Zig with ZLS
       yaml                                 ; YAML

       :email

       :app

       :config
       (default +bindings +smartparens))