;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Ensure syntax highlighting is always on
(global-font-lock-mode 1)
(add-hook 'doom-after-init-hook (lambda () (global-font-lock-mode 1)))
(add-hook 'prog-mode-hook    #'turn-on-font-lock)
(add-hook 'text-mode-hook    #'turn-on-font-lock)
(add-hook 'conf-mode-hook    #'turn-on-font-lock)
(add-hook 'fundamental-mode-hook #'turn-on-font-lock)

;; ============================================================================
;; Identity
;; ============================================================================
;; Uncomment and fill in for GPG, email, git-related features
;; (setq user-full-name "Your Name"
;;       user-mail-address "you@example.com")

;; ============================================================================
;; Theme & Appearance -- Alabaster Light
;; ============================================================================
;;
;; Alabaster philosophy: most code is plain black. Only 4 things get color:
;;   1. Strings    -> green   #448c27
;;   2. Constants  -> purple  #7a3e9d
;;   3. Comments   -> red     #aa3731
;;   4. Definitions (declarations) -> blue #325cc0

;; Use doom-plain as a minimal base, then override with alabaster colors
(setq doom-theme 'doom-plain)

;; Apply alabaster color overrides after the theme loads
(custom-set-faces!
  ;; -- Base editor colors --
  '(default                      :foreground "#000000" :background "#f7f7f7")
  '(cursor                       :background "#007acc")
  '(region                       :background "#bfdbfe")           ; visual selection
  '(hl-line                      :background "#E2EEEE")           ; cursor line
  '(line-number                  :foreground "#7d7c7c")
  '(line-number-current-line     :foreground "#325cc0" :weight bold)
  '(vertical-border              :foreground "#abbdc0")
  '(fringe                       :background "#f7f7f7")
  '(mode-line                    :foreground "#222222" :background "#c9c9c9")
  '(mode-line-inactive           :foreground "#666666" :background "#c9c9c9")
  '(fill-column-indicator        :foreground "#E2EEEE")           ; column ruler
  '(shadow                       :foreground "#7d7d7d")
  '(trailing-whitespace          :background "#f8b28f")
  '(match                        :background "#fae9b7")           ; search match
  '(isearch                      :foreground "#000000" :background "#ffbc5d")
  '(lazy-highlight               :foreground "#000000" :background "#fae9b7")
  '(show-paren-match             :underline (:color "#ffbc5d" :style line))

  ;; -- Popup menu (completion, etc.) --
  '(corfu-default                :background "#e7e7e7")
  '(corfu-current                :background "#c7c7c7")
  '(completions-common-part      :foreground "#325cc0")

  ;; -- Syntax: the alabaster way --
  ;; Most things are black (default). Only strings, constants, comments, definitions.
  '(font-lock-comment-face       :foreground "#aa3731")           ; red comments
  '(font-lock-comment-delimiter-face :foreground "#aa3731")
  '(font-lock-doc-face           :foreground "#aa3731")
  '(font-lock-string-face        :foreground "#448c27")           ; green strings
  '(font-lock-constant-face      :foreground "#7a3e9d")           ; purple constants
  '(font-lock-number-face        :foreground "#7a3e9d")           ; purple numbers
  '(font-lock-builtin-face       :foreground "#7a3e9d")           ; purple builtins
  '(font-lock-keyword-face       :foreground "#000000")           ; black (by design)
  '(font-lock-function-name-face :foreground "#325cc0")           ; blue definitions
  '(font-lock-function-call-face :foreground "#000000")           ; black (not a decl)
  '(font-lock-variable-name-face :foreground "#000000")           ; black
  '(font-lock-variable-use-face  :foreground "#000000")           ; black
  '(font-lock-type-face          :foreground "#000000")           ; black
  '(font-lock-property-name-face :foreground "#000000")           ; black
  '(font-lock-property-use-face  :foreground "#000000")           ; black
  '(font-lock-operator-face      :foreground "#777777")           ; grey punctuation
  '(font-lock-punctuation-face   :foreground "#777777")           ; grey punctuation
  '(font-lock-bracket-face       :foreground "#777777")           ; grey brackets
  '(font-lock-delimiter-face     :foreground "#777777")           ; grey delimiters
  '(font-lock-negation-char-face :foreground "#777777")
  '(font-lock-escape-face        :foreground "#cb9000")           ; yellow escapes
  '(font-lock-preprocessor-face  :foreground "#000000")
  '(font-lock-warning-face       :foreground "#cb9000")

  ;; -- Tree-sitter faces (Emacs 30) --
  '(tree-sitter-hl-face:comment          :foreground "#aa3731")
  '(tree-sitter-hl-face:string           :foreground "#448c27")
  '(tree-sitter-hl-face:number           :foreground "#7a3e9d")
  '(tree-sitter-hl-face:constant         :foreground "#7a3e9d")
  '(tree-sitter-hl-face:constant.builtin :foreground "#7a3e9d")
  '(tree-sitter-hl-face:keyword          :foreground "#000000")
  '(tree-sitter-hl-face:function         :foreground "#000000")
  '(tree-sitter-hl-face:function.call    :foreground "#000000")
  '(tree-sitter-hl-face:method           :foreground "#000000")
  '(tree-sitter-hl-face:method.call      :foreground "#000000")
  '(tree-sitter-hl-face:type             :foreground "#000000")
  '(tree-sitter-hl-face:type.builtin     :foreground "#000000")
  '(tree-sitter-hl-face:variable         :foreground "#000000")
  '(tree-sitter-hl-face:variable.builtin :foreground "#7a3e9d")
  '(tree-sitter-hl-face:property         :foreground "#000000")
  '(tree-sitter-hl-face:operator         :foreground "#777777")
  '(tree-sitter-hl-face:punctuation      :foreground "#777777")
  '(tree-sitter-hl-face:punctuation.bracket    :foreground "#777777")
  '(tree-sitter-hl-face:punctuation.delimiter  :foreground "#777777")

  ;; -- Diff / Git gutter (match gitsigns colors) --
  '(diff-hl-insert               :foreground "#6abf40")
  '(diff-hl-change               :foreground "#ec8013")
  '(diff-hl-delete               :foreground "#B40600")
  '(diff-added                   :foreground "#0A7816" :background "#ADFFB7")
  '(diff-removed                 :foreground "#872C28" :background "#F8B28F")
  '(diff-changed                 :foreground "#341a00" :background "#fff987")

  ;; -- Diagnostics --
  '(error                        :foreground "#d13e23")
  '(warning                      :foreground "#BC7500")
  '(success                      :foreground "#278C00")
  '(flycheck-error               :underline (:color "#d13e23" :style wave))
  '(flycheck-warning             :underline (:color "#BC7500" :style wave))
  '(flycheck-info                :underline (:color "#278C00" :style wave))
  '(flymake-error                :underline (:color "#d13e23" :style wave))
  '(flymake-warning              :underline (:color "#BC7500" :style wave))
  '(flymake-note                 :underline (:color "#278C00" :style wave))

  ;; -- hl-todo --
  '(hl-todo                      :foreground "#325cc0" :background "#FFDEAA" :weight bold)

  ;; -- Treemacs --
  '(treemacs-root-face           :foreground "#325cc0" :weight bold)

  ;; -- centaur-tabs --
  '(centaur-tabs-selected        :background "#f7f7f7" :foreground "#000000")
  '(centaur-tabs-unselected      :background "#e7e7e7" :foreground "#7d7d7d")
  '(centaur-tabs-selected-modified  :background "#f7f7f7" :foreground "#d13e23")
  '(centaur-tabs-unselected-modified :background "#e7e7e7" :foreground "#d13e23"))

;; Font -- adjust family/size to your preference
;; (setq doom-font (font-spec :family "JetBrains Mono" :size 14)
;;       doom-variable-pitch-font (font-spec :family "Inter" :size 14))

;; Relative line numbers (like set.rnu = true)
(setq display-line-numbers-type 'relative)

;; Column rulers at 80 and 100 (like set.colorcolumn = {'80', '100'})
(add-hook! '(prog-mode-hook text-mode-hook)
  (setq-local display-fill-column-indicator-column 80)
  (display-fill-column-indicator-mode 1))

;; Show a second ruler at 100 via whitespace-mode
(setq whitespace-line-column 100
      whitespace-style '(face lines-tail))

;; No line wrapping (like set.wrap = false)
(setq-default truncate-lines t)

;; Show trailing whitespace and tabs (like set.list = true with listchars)
(setq-default show-trailing-whitespace t)

;; Sign column equivalent -- fringe is always visible
(setq-default left-fringe-width 8)

;; Disable folding by default (like set.foldenable = false)
(setq-default +fold-on-open nil)

;; ============================================================================
;; Splits & Windows
;; ============================================================================

;; New splits open right and below (like splitright/splitbelow)
(setq evil-vsplit-window-right t
      evil-split-window-below t)

;; ============================================================================
;; Clipboard
;; ============================================================================

;; Use system clipboard (like set.clipboard = "unnamedplus")
(setq select-enable-clipboard t
      select-enable-primary t)

;; ============================================================================
;; Scrolling
;; ============================================================================

;; Built-in pixel-level smooth scrolling in Emacs 30
(pixel-scroll-precision-mode 1)

;; ============================================================================
;; Tabs / Buffer navigation  (like bufferline with S-h / S-l)
;; ============================================================================

;; centaur-tabs is enabled via the `tabs` module
(after! centaur-tabs
  (setq centaur-tabs-style "bar"
        centaur-tabs-set-icons t
        centaur-tabs-set-bar 'under
        centaur-tabs-set-modified-marker t
        centaur-tabs-modified-marker "*"))

;; Buffer cycling with Shift-h / Shift-l (like your BufferLineCyclePrev/Next)
(map! :n "H" #'centaur-tabs-backward
      :n "L" #'centaur-tabs-forward
      ;; Move tabs with Shift-j / Shift-k (like BufferLineMovePrev/Next)
      :n "J" #'centaur-tabs-move-current-tab-to-left
      :n "K" #'centaur-tabs-move-current-tab-to-right)

;; ============================================================================
;; Window / Split navigation (like tmux-navigator with C-h/j/k/l)
;; ============================================================================

(map! :n "C-h" #'evil-window-left
      :n "C-j" #'evil-window-down
      :n "C-k" #'evil-window-up
      :n "C-l" #'evil-window-right)

;; Make C-h/j/k/l work from inside Treemacs too
(after! treemacs-evil
  (evil-define-key 'treemacs treemacs-mode-map
    (kbd "C-h") #'evil-window-left
    (kbd "C-j") #'evil-window-down
    (kbd "C-k") #'evil-window-up
    (kbd "C-l") #'evil-window-right)
  ;; Also in the state map as fallback
  (define-key evil-treemacs-state-map (kbd "C-h") #'evil-window-left)
  (define-key evil-treemacs-state-map (kbd "C-j") #'evil-window-down)
  (define-key evil-treemacs-state-map (kbd "C-k") #'evil-window-up)
  (define-key evil-treemacs-state-map (kbd "C-l") #'evil-window-right))

;; Split resizing (like your > and < mappings)
(map! :n ">" (cmd! (evil-window-increase-width 10))
      :n "<" (cmd! (evil-window-decrease-width 10)))

;; ============================================================================
;; Leader key bindings
;; ============================================================================

;; Close buffer (like <leader>q -> :bp|sp|bn|bd)
(map! :leader
      :desc "Kill buffer" "q" #'kill-current-buffer)

;; Copy file path to clipboard (like your yy mapping)
(map! :n "yy" (cmd! (kill-new (buffer-file-name))
                     (message "Copied: %s" (buffer-file-name))))

;; Clear search highlight with Enter (like your <CR> -> :noh)
(map! :n "RET" #'evil-ex-nohighlight)

;; ============================================================================
;; Custom Airline-style Modeline
;; ============================================================================
;;
;; Matches the lualine alabaster light theme exactly:
;;   Section A (mode/location): accent bg that changes with evil state
;;   Sections B+C (everything else): #c9c9c9 bg (same as mode-line)
;;   Powerline  /  separators between A and B only
;;
;; Layout: [A: mode]▶[B+C: branch filename ... info lsp]◀[Z: line:col]

;; --- Alabaster light palette (from lualine/themes/alabaster.lua) ---
(defvar ml/bg     "#c9c9c9")   ; color1 – sections B, C, X, Y background
(defvar ml/fg     "#222222")   ; color3 – primary foreground
(defvar ml/fg-dim "#666666")   ; color4 – inactive foreground

;; Section A accent per evil state: (fg . bg)
(defvar ml/acc-normal  '("#222222" . "#aaaaaa"))   ; color3 on color5
(defvar ml/acc-insert  '("#c9c9c9" . "#222222"))   ; color1 on color3
(defvar ml/acc-visual  '("#c9c9c9" . "#7a3e9d"))   ; color1 on color6
(defvar ml/acc-replace '("#c9c9c9" . "#cb9000"))   ; color1 on color2

;; --- Powerline glyphs (Nerd Font) ---
(defvar ml/ar (char-to-string #xe0b0))   ; 
(defvar ml/al (char-to-string #xe0b2))   ; 

;; --- Accent lookup ---
(defun ml/accent ()
  "Return (fg . bg) for the current evil state."
  (cond
   ((not (bound-and-true-p evil-local-mode)) ml/acc-normal)
   ((evil-insert-state-p)  ml/acc-insert)
   ((evil-visual-state-p)  ml/acc-visual)
   ((evil-replace-state-p) ml/acc-replace)
   (t                      ml/acc-normal)))

;; --- Segment helpers ---
(defun ml/evil-tag ()
  (if (bound-and-true-p evil-local-mode)
      (cond ((evil-normal-state-p)   " NORMAL ")
            ((evil-insert-state-p)   " INSERT ")
            ((evil-visual-state-p)   " VISUAL ")
            ((evil-replace-state-p)  " REPLACE ")
            ((evil-emacs-state-p)    " EMACS ")
            ((evil-operator-state-p) " O-PEND ")
            ((evil-motion-state-p)   " MOTION ")
            (t                       " NORMAL "))
    " EMACS "))

(defun ml/branch ()
  (when vc-mode
    (let ((b (replace-regexp-in-string
              "^ Git[:-]" "" (substring-no-properties vc-mode))))
      (format " %c %s " #xe0a0 b))))

(defun ml/bufname ()
  (let* ((name (if (buffer-file-name)
                   (file-relative-name
                    (buffer-file-name)
                    (or (and (fboundp 'projectile-project-root)
                             (projectile-project-root))
                        default-directory))
                 (buffer-name)))
         (mod (if (and (buffer-file-name) (buffer-modified-p)) " [+]" "")))
    (format " %s%s " name mod)))

(defun ml/info ()
  (let* ((sys (symbol-name buffer-file-coding-system))
         (enc (cond ((string-match-p "utf-8" sys) "utf-8")
                    ((string-match-p "utf-16" sys) "utf-16")
                    ((string-match-p "latin" sys) "latin-1")
                    (t sys)))
         (eol (pcase (coding-system-eol-type buffer-file-coding-system)
                (0 "unix") (1 "dos") (2 "mac") (_ "")))
         (ft (replace-regexp-in-string
              "-ts-mode$\\|-mode$" "" (symbol-name major-mode)))
         (icon (when (fboundp 'nerd-icons-icon-for-mode)
                 (let ((i (nerd-icons-icon-for-mode major-mode)))
                   (when (stringp i) (concat (substring-no-properties i) " "))))))
    (format " %s  %s  %s%s " enc eol (or icon "") ft)))

(defun ml/lsp ()
  (if (and (bound-and-true-p eglot--managed-mode)
           (eglot-current-server))
      " LSP " nil))

(defun ml/pos ()
  (format " %d:%d " (line-number-at-pos) (1+ (current-column))))

;; --- Render ---
(defun ml/render-left ()
  (let* ((active (mode-line-window-selected-p))
         (acc (ml/accent))
         (afg (car acc))
         (abg (cdr acc)))
    (if active
        (concat
         (propertize (ml/evil-tag)
                     'face `(:foreground ,afg :background ,abg :weight bold))
         (propertize ml/ar
                     'face `(:foreground ,abg :background ,ml/bg))
         (propertize (concat (or (ml/branch) "") (ml/bufname))
                     'face `(:foreground ,ml/fg :background ,ml/bg)))
      (propertize (concat " " (ml/bufname))
                  'face `(:foreground ,ml/fg-dim :background ,ml/bg)))))

(defun ml/render-right ()
  (let* ((active (mode-line-window-selected-p))
         (acc (ml/accent))
         (afg (car acc))
         (abg (cdr acc)))
    (if active
        (concat
         (propertize (concat (ml/info) (or (ml/lsp) ""))
                     'face `(:foreground ,ml/fg :background ,ml/bg))
         (propertize ml/al
                     'face `(:foreground ,abg :background ,ml/bg))
         (propertize (ml/pos)
                     'face `(:foreground ,afg :background ,abg :weight bold)))
      (propertize (concat (ml/info) (ml/pos))
                  'face `(:foreground ,ml/fg-dim :background ,ml/bg)))))

;; --- Install ---
;; Disable doom-modeline after init and set our custom format.
;; Uses doom-after-init-hook with :append to run after everything else.
(add-hook! 'doom-after-init-hook :append
  (defun ml/install ()
    (when (bound-and-true-p doom-modeline-mode)
      (doom-modeline-mode -1))
    (setq-default mode-line-format
                  '((:eval (ml/render-left))
                    mode-line-format-right-align
                    (:eval (ml/render-right))))
    ;; Also set for all existing buffers
    (dolist (buf (buffer-list))
      (with-current-buffer buf
        (setq mode-line-format
              '((:eval (ml/render-left))
                mode-line-format-right-align
                (:eval (ml/render-right))))))
    (force-mode-line-update t)))

;; ============================================================================
;; Treemacs (file explorer, like nvim-tree)
;; ============================================================================

;; Toggle treemacs with SPC o p (Doom default) or add your own:
(after! treemacs
  (setq treemacs-width 35
        treemacs-position 'left))

;; ============================================================================
;; LSP (via eglot, built into Emacs 30)
;; ============================================================================

;; Hover docs (like your M -> vim.lsp.buf.hover)
(map! :n "M" #'+lookup/documentation)

;; LSP keybindings in normal mode matching your Neovim setup:
;;   gd  -> go to definition       (Doom default: works out of the box)
;;   gi  -> go to implementation
;;   gr  -> find references
;;   <leader>rn -> rename
;;   <leader>ca -> code action
(map! :n "gi" #'+lookup/implementations
      :n "gr" #'+lookup/references
      :leader
      :desc "Rename symbol" "r n" #'eglot-rename
      :desc "Code action"   "c a" #'eglot-code-actions)

;; Show diagnostics on hover (like your CursorHold autocmd)
(setq eldoc-idle-delay 0.25)

;; ============================================================================
;; Autocompletion (corfu)
;; ============================================================================

(after! corfu
  (setq corfu-auto t              ; auto-trigger completion
        corfu-auto-prefix 2       ; trigger after 2 chars
        corfu-auto-delay 0.2      ; 200ms delay
        corfu-preselect 'prompt   ; don't preselect first candidate
        corfu-count 10            ; show 10 candidates
        corfu-scroll-margin 3))   ; margin at top/bottom

;; ============================================================================
;; Avy (like Flash.nvim / EasyMotion)
;; ============================================================================

;; Doom already binds `gs SPC` for avy-goto-char-timer and others.
;; Let's also add `s` for quick jump (like your Flash `s` binding):
(map! :n "s" #'evil-avy-goto-char-2
      :n "S" #'evil-avy-goto-line)

;; ============================================================================
;; Magit (Git -- way beyond gitsigns, this is the killer Emacs feature)
;; ============================================================================

;; SPC g g   -> open Magit status (Doom default)
;; SPC g b   -> blame
;; SPC g l   -> log
;; All defaults are great, no extra config needed.

;; ============================================================================
;; Format on save
;; ============================================================================

;; The (format +onsave) module handles this. Configure per-language formatters:
(setq +format-on-save-disabled-modes
      '(emacs-lisp-mode    ; don't auto-format elisp
        sql-mode
        tex-mode
        latex-mode))

;; ============================================================================
;; Tmux integration
;; ============================================================================

;; If running inside tmux, integrate window navigation
(use-package! tmux-pane
  :when (getenv "TMUX")
  :config
  (tmux-pane-mode 1)
  ;; Override C-h/j/k/l to be tmux-aware (like vim-tmux-navigator)
  (map! :n "C-h" #'tmux-pane-omni-window-left
        :n "C-j" #'tmux-pane-omni-window-down
        :n "C-k" #'tmux-pane-omni-window-up
        :n "C-l" #'tmux-pane-omni-window-right)
  ;; Also override in treemacs when in tmux
  (after! treemacs-evil
    (evil-define-key 'treemacs treemacs-mode-map
      (kbd "C-h") #'tmux-pane-omni-window-left
      (kbd "C-j") #'tmux-pane-omni-window-down
      (kbd "C-k") #'tmux-pane-omni-window-up
      (kbd "C-l") #'tmux-pane-omni-window-right)))

;; ============================================================================
;; Org mode directory
;; ============================================================================

(setq org-directory "~/org/")

;; ============================================================================
;; Gleam support (basic -- major mode + LSP)
;; ============================================================================

(use-package! gleam-ts-mode
  :mode "\\.gleam\\'"
  :config
  (add-hook 'gleam-ts-mode-hook #'eglot-ensure))

;; ============================================================================
;; Misc
;; ============================================================================

;; Backup files to /tmp (like your set.backupdir = '/tmp')
(setq backup-directory-alist `(("." . ,temporary-file-directory))
      auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;; Faster which-key popup (shows available keys after pressing leader)
(setq which-key-idle-delay 0.3)

;; Symbols outline (like your mm -> :SymbolsOutline mapping)
;; Using consult-imenu which works with eglot
(map! :n "mm" #'consult-imenu)

;; ============================================================================
;; Tree-sitter grammars
;; ============================================================================

;; Tell Emacs where the grammars live (treesit-auto installed them here)
(setq treesit-extra-load-path
      (list (expand-file-name ".local/etc/tree-sitter/" doom-emacs-dir)))

(use-package! treesit-auto
  :config
  (setq treesit-auto-install 'prompt)
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))