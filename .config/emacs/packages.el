;; Set up package repositories
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

(use-package evil-commentary
  :ensure t
  :after evil
  :config
  (evil-commentary-mode))

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

(use-package dashboard
  :ensure t
  :demand t)

(use-package centaur-tabs
  :ensure t
  :after (alabaster-themes nerd-icons)
  :init
  (custom-set-faces
   '(centaur-tabs-active-bar-face ((t (:background "#FFBC5D"))))))

(use-package xclip
  :ensure t
  :after evil)

(use-package neotree
  :ensure t
  :after nerd-icons)

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
  :hook (prog-mode . flymake-mode))

(use-package flymake-eslint
  :ensure t
  :after eglot)

(use-package flymake-popon
  :ensure t
  :hook (flymake-mode . flymake-popon-mode))

(use-package consult
  :ensure t)

(use-package treesit-auto
  :ensure t
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package telephone-line
  :ensure t
  :demand t)
