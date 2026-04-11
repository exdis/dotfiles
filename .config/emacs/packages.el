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
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode 1))

(use-package evil-collection
  :ensure t
  :after evil
  :config
  (evil-collection-init '(neotree)))

(use-package ligature
  :ensure t
  :config
  (ligature-set-ligatures 'prog-mode
    '(;; == === ==== => =| =>>=>=|=>==>> ==< =/=//=// =~
      ;; =:= =!=
      ("=" (rx (+ (or ">" "<" "|" "/" "~" ":" "!" "="))))
      ;; ;; ;;;
      (";" (rx (+ ";")))
      ;; && &&&
      ("&" (rx (+ "&")))
      ;; !! !!! !. !: !!. != !== !~
      ("!" (rx (+ (or "=" "!" "\\." ":" "~"))))
      ;; ?? ??? ?:  ?=  ?.
      ("?" (rx (or ":" "=" "\\." (+ "?"))))
      ;; %% %%%
      ("%" (rx (+ "%")))
      ;; |> ||> |||> ||||> |] |} || ||| |-> ||-||
      ;; |->>-||-<<-| |- |== ||=||
      ;; |==>>==<<==<=>==//==/=!==:===>
      ("|" (rx (+ (or ">" "<" "|" "/" ":" "!" "}" "\\]"
                      "-" "=" ))))
      ;; \\ \\\\ \\/
      ("\\" (rx (or "/" (+ "\\\\"))))
      ;; ++ +++ ++++ +>
      ("+" (rx (or ">" (+ "+"))))
      ;; :: ::: :::: :> :< := :// ::=
      (":" (rx (or ">" "<" "=" "//" ":=" (+ ":"))))
      ;; // /// //// /\\ /\* /> /===:===!=//===>>==>==/
      ("/" (rx (+ (or ">"  "<" "|" "/" "\\\\" "\\*" ":" "!"
                      "="))))
      ;; .. ... .... .= .- .? ..= ..<
      ("." (rx (or "=" "-" "\\?" "\\.=" "\\.<" (+ "\\."))))
      ;; -- --- ---- -~ -> ->> -| -|->-->>->--<<-|
      ("-" (rx (+ (or ">" "<" "|" "~" "-"))))
      ;; *> */ *)  ** *** ****
      ("*" (rx (or ">" "/" ")" (+ "*"))))
      ;; www wwww
      ("w" (rx (+ "w")))
      ;; <> <!-- <|> <: <~ <~> <~~ <+ <* <$ </  <+> <*>
      ;; <$> </> <|  <||  <||| <|||| <- <## <## <### <####
      ;; <<-> <= <=> <<==<<==>=|=>==/==//=!==:=>
      ;; << <<< <<<<
      ("<" (rx (+ (or "\\+" "\\*" "\\$" "<" ">" ":" "~"  "!"
                      "-"  "/" "|" "="))))
      ;; >: >- >>- >--|-> >>## >= >== >>== >=|=:=>>
      ;; >> >>> >>>>
      (">" (rx (+ (or ">" "<" "|" "/" ":" "=" "-"))))
      ;; #: #= #! #( #? #[ #{ #_ #_( ## ### #####
      ("#" (rx (or ":" "=" "!" "(" "\\?" "\\[" "{" "_(" "_"
                   (+ "#"))))
      ;; ~~ ~~~ ~=  ~-  ~@ ~> ~~>
      ("~" (rx (or ">" "=" "-" "@" "~>" (+ "~"))))
      ;; __ ___ ____ _|_ __|____|_
      ("_" (rx (+ (or "_" "|"))))
      ;; Fira code: 0xFF 0x12
      ("0" (rx (and "x" (+ (in "A-F" "a-f" "0-9")))))
      ;; Fira code:
      "Fl"  "Tl"  "fi"  "fj"  "fl"  "ft"
      ;; The few not covered by the regexps.
      "{|"  "[|"  "]#"  "(*"  "}#"  "$>"  "^="))
  (global-ligature-mode t))

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
  (orderless-matching-styles '(orderless-literal orderless-regexp orderless-flex))
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

(use-package flymake
  :hook (prog-mode . flymake-mode)
  :config
  (setq flymake-margin-indicators-string
	'((error "!!" compilation-error)
	  (warning "?" compilation-warning)
	  (note "·" compilation-info))))

(use-package flymake-eslint
  :ensure t
  :after eglot
  :config
  (setq flymake-eslint-prefer-json-diagnostics t)
  (defun my/add-node-modules-path ()
    "Add node_modules/.bin to exec-path for the current buffer."
    (let ((root (locate-dominating-file default-directory "node_modules")))
      (when root
        (make-local-variable 'exec-path)
        (add-to-list 'exec-path (expand-file-name "node_modules/.bin" root)))))
  (defun my/flymake-eslint-after-eglot ()
    "Add eslint backend after eglot has set up flymake."
    (when (and (bound-and-true-p eglot--managed-mode)
               (derived-mode-p 'js-ts-mode 'typescript-ts-mode 'tsx-ts-mode))
      (my/add-node-modules-path)
      (flymake-eslint-enable)))
  (add-hook 'eglot-managed-mode-hook #'my/flymake-eslint-after-eglot)
  (defun my/disable-flymake-eldoc ()
    "Remove flymake from eldoc so diagnostics only show in popon."
    (setq-local eldoc-documentation-functions
		(remove #'flymake-eldoc-function eldoc-documentation-functions)))
  (add-hook 'eglot-managed-mode-hook #'my/disable-flymake-eldoc 100))

(use-package flymake-popon
  :ensure t
  :hook (flymake-mode . flymake-popon-mode)
  :config
  (setq flymake-popon-method 'popon)
  (setq flymake-popon-width 70)
  (defun my/flymake-popon-format-diagnostic (diagnostic)
    "Format DIAGNOSTIC with a box-drawing border."
    (let* ((text (flymake-diagnostic-text diagnostic))
           (type (flymake-diagnostic-type diagnostic))
           (face (flymake--lookup-type-property type 'mode-line-face))
           (icon (pcase type
                   (:error "✗")
                   (:warning "⚠")
                   (_ "·")))
           ;; Split text into first line and rest
           (lines (split-string text "[\n\r]"))
           (first-line (concat icon " " (car lines)))
           (rest-lines (cdr lines))
           ;; Build all content lines
           (all-lines (cons first-line rest-lines))
           ;; Inner width (content area, -4 for "│ " and " │")
           (inner-width (- flymake-popon-width 4))
           ;; Word-wrap and pad each line
           (wrapped '())
           (top (concat "┌" (make-string (+ inner-width 2) ?─) "┐"))
           (bottom (concat "└" (make-string (+ inner-width 2) ?─) "┘")))
      ;; Wrap long lines and collect them
      (dolist (line all-lines)
        (if (<= (length line) inner-width)
            (push line wrapped)
          ;; Simple word wrap
          (let ((remaining line))
            (while (> (length remaining) inner-width)
              (let ((break-pos (or (cl-position ?\s remaining
                                                :from-end t
                                                :end inner-width)
                                   inner-width)))
                (push (substring remaining 0 break-pos) wrapped)
                (setq remaining (string-trim-left
                                 (substring remaining break-pos)))))
            (when (> (length remaining) 0)
              (push remaining wrapped)))))
      (setq wrapped (nreverse wrapped))
      ;; Build bordered output
      (let ((body (mapconcat
                   (lambda (line)
                     (let ((padded (concat line
                                          (make-string
                                           (max 0 (- inner-width (length line)))
                                           ?\s))))
                       (concat "│ " padded " │")))
                   wrapped "\n")))
        (concat top "\n" body "\n" bottom)))))

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
