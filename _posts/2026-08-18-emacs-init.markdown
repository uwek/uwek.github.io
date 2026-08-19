---
layout: post
title:  "Zuerst der Werkzeugkasten: Emacs"
date:   2026-08-17 21:00:00 +0200
categories: emacs org
---

Obwohl ich keinen heiligen Krieg entfachen will - Emacs ist und bleibt das beste Werkzeug, um 
in einer Terminalumgebung mit Org- und Markdown-Files, mit BibTeX-Verzeichnissen und 
Automatisierungen umzugehen. Die Konfiguration von Emacs hängt sehr von persönlichen Vorlieben ab 
und ist so individuell wie ein Fingerabdruck.

<!--more-->

Hier ist meine:

Hilfreiche Standard-Shortcuts

> ^x ^q - editable dired mode


# relative paths

```emacs-lisp
(buffer-file-name)
```

```emacs-lisp
(setq my/initfile "/home/uwek/uwek.github.io/_org/2026-08-18-emacs-init.org")
(defun my/localfile (fname)
  (expand-file-name (concat (file-name-directory my/initfile) fname)))
```


# Config


# sane defaults

```emacs-lisp
    ;; (if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
    (if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
    (if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

    ;;(setq warning-minimum-level :error)
    (setq custom-file (make-temp-file "emacs-custom"))
    (setq visible-bell 1)
    (setq inhibit-startup-screen t)
    (defalias 'yes-or-no-p 'y-or-n-p)
    (setq make-backup-files nil)
    (show-paren-mode)
    (electric-indent-mode -1)

    (recentf-mode 1)
    (setq history-length 25)
    (savehist-mode 1)
    (save-place-mode 1)
    (global-auto-revert-mode 1)
    (setq global-auto-revert-non-file-buffers t)

    (setq system-time-locale "de_DE.UTF-8")
    (prefer-coding-system 'utf-8-unix)
    (set-default-coding-systems 'utf-8-unix)
    (set-terminal-coding-system 'utf-8-unix)
    (set-keyboard-coding-system 'utf-8-unix)

;; (xterm-mouse-mode 1)
;; (xterm-mouse-mode 0)

    (load-theme 'modus-vivendi)
```


# use-package

```emacs-lisp
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives '(("org"   . "http://orgmode.org/elpa/")
                         ("gnu"   . "http://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)
;; Bootstrap `use-package`
(setq package-check-signature nil)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)
(setq use-package-always-defer nil)
(setq use-package-verbose t)
(setq use-package-compute-statistics t)

(use-package diminish)
```


# package: general

```emacs-lisp
(use-package general
  :config
  (general-evil-setup t)
  (general-auto-unbind-keys)
  (general-create-definer my/leader-keys
    :keymaps 'override
    :states '(normal insert visual emacs)
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC" ;; access leader in insert mode
    ))
```


# package: eyebrowse

```emacs-lisp
(use-package eyebrowse :ensure t
  :diminish eyebrowse-mode
  :config
  (eyebrowse-mode t)
  (setq eyebrowse-new-workspace t))
```


# dired

```emacs-lisp
(use-package dired
  :ensure nil ;; built-in
  :defer t
  ;; :hook
  ;;   (dired-mode . dired-hide-details-mode)
  :config
  (setq dired-dwim-target t)                  ;; do what I mean
  (setq dired-recursive-copies 'always)       ;; don't ask when copying directories
  (setq dired-create-destination-dirs 'ask)   
  (setq dired-clean-confirm-killing-deleted-buffers nil)
  (setq dired-make-directory-clickable t)
  (setq dired-mouse-drag-files t)
  (setq dired-kill-when-opening-new-dired-buffer t)   ;; Tidy up open buffers by default
)

(when (eq system-type 'darwin)
  (let ((gls (executable-find "gls")))
    (when gls
      (setq dired-use-ls-dired t
            insert-directory-program gls
            dired-listing-switches "-aBhl  --group-directories-first"))))

(setq dired-recursive-copies 'top)
(setq dired-recursive-deletes 'top)
;; (setq dired-use-ls-dired nil)
;; (dired-hide-details-mode)

```


# package: complete - marginalia

```emacs-lisp
(use-package marginalia
  :custom
  (marginalia-max-relative-age 0)
  ;; (marginalia-align 'right)
  :init
  (marginalia-mode))
```


# package: complete - vertico

```emacs-lisp
(use-package vertico
  :custom
  ;; (vertico-count 13)                    ; Number of candidates to display
  ;; (vertico-resize t)
  (vertico-cycle nil) ; Go from last to first candidate and first to last (cycle)?
  :config
  (define-key vertico-map (kbd "C-c C-c") #'vertico-exit-input)
  (vertico-mode))
```


# package: complete - orderless

```emacs-lisp
(use-package orderless
  :custom
  (completion-styles '(orderless))      ; Use orderless
  ;; (completion-category-defaults nil)    ; I want to be in control!
  ;; (completion-category-overrides
  ;;  '((file (styles basic-remote ; For `tramp' hostname completion with `vertico'
  ;;                  orderless))))
  )
```


# package: which-key

```emacs-lisp
(use-package which-key
  :diminish
  :config
  (which-key-mode 1))
```


# package: doom-modeline

```emacs-lisp
(use-package doom-modeline
  :config
  (setq doom-modeline-buffer-encoding nil)
  (setq doom-modeline-icon nil)
  (setq doom-modeline-enable-word-count t)
 (display-battery-mode 1)
  (doom-modeline-mode))
```


# package: gptel

<https://github.com/karthink/gptel>

```emacs-lisp
  (use-package gptel
;;  :init
;;  (setq gptel-api-key my/api_openai)i
)
```

;; OpenRouter offers an OpenAI compatible API
(gptel-make-openai "OpenRouter"               ;Any name you want
  :host "openrouter.ai"
  :endpoint "/api/v1/chat/completions"
  :stream t
  :key "your-api-key"                   ;can be a function that returns the key
  :models '(openai/gpt-3.5-turbo
            mistralai/mixtral-8x7b-instruct
            meta-llama/codellama-34b-instruct
            codellama/codellama-70b-instruct
            google/palm-2-codechat-bison-32k
            google/gemini-pro))


# eww

R  - readable view
bB - Bookmark(s)
G  - Goto

```emacs-lisp
(require 'url-http)
(if (not (window-system))
    (progn
      (setq browse-url-browser-function 'eww-browse-url)
      (setq url-user-agent "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3739.0 Safari/537.36\n") (setq shr-use-colors nil)
      ))

(add-hook 'eww-after-render-hook #'eww-readable)
```


# org-mode basic

```emacs-lisp
(require 'org-tempo)
(require 'org-inlinetask)
(setq org-use-speed-commands t
      org-support-shift-select 1 
      org-log-done 'time
      org-cite-global-bibliography (list (my/localfile "../_bibliography/references.bib"))
      ebib-preload-bib-files (list (my/localfile "../_bibliography/references.bib"))
      ispell-program-name "hunspell")

(setq bibtex-autokey-year-length 4
      bibtex-autokey-name-year-separator ""
      bibtex-autokey-titlewords 0
      bibtex-autokey-titleword-length nil)

;; Ohne dies bricht ebib bei einem Key-Duplikat ab, statt "2026a",
;; "2026b" usw. anzuhängen.
(setq ebib-uniquify-keys t)

(defun my/org-setup ()
  (interactive)
  (visual-line-mode))
(add-hook 'org-mode-hook 'my/org-setup)
```

(use-package citar
:custom
(citar-bibliography org-cite-global-bibliography)
(citar-notes-paths (list (my/localfile "../<sub>bibliography</sub>/")))
(citar-file-note-extensions (list "org"))
(org-cite-insert-processor 'citar)
(org-cite-follow-processor 'citar)
(org-cite-activate-processor 'citar))


# my/org-narrow-toggle

```emacs-lisp
(defun my/org-narrow-toggle ()
  "Toggle org narrow subtreee / show everything"
  (interactive)
  (if (buffer-narrowed-p)
      (widen)
    (org-narrow-to-subtree)))

```

;;  (general-define-key
;;   (my/nav-key "<") '(my/org-narrow-toggle :wk "toggle subtree"))


# evil-mode

```emacs-lisp
(use-package evil
  :init      ;; tweak evil's configuration before loading it
  (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (setq evil-move-beyond-eol t)
  (setq evil-respect-visual-line-mode t)
  (evil-mode)
  ) 

(use-package evil-collection
  :after evil
  :config
  (setq evil-collection-mode-list '(dashboard ibuffer)) 
  ;; (setq evil-collection-mode-list '(dashboard dired ibuffer)) 
  (evil-collection-init)) 

;; Using RETURN to follow links in Org/Evil 
;; Unmap keys in 'evil-maps if not done, (setq org-return-follows-link t) will not work
(with-eval-after-load 'evil-maps
  ;; Make movement keys work like they should
  (define-key evil-normal-state-map (kbd "<remap> <evil-next-line>") 'evil-next-visual-line)
  (define-key evil-normal-state-map (kbd "<remap> <evil-previous-line>") 'evil-previous-visual-line)
  (define-key evil-motion-state-map (kbd "<remap> <evil-next-line>") 'evil-next-visual-line)
  (define-key evil-motion-state-map (kbd "<remap> <evil-previous-line>") 'evil-previous-visual-line)
  (define-key evil-motion-state-map (kbd "SPC") nil)
  (define-key evil-motion-state-map (kbd "RET") nil)
  (define-key evil-motion-state-map (kbd "TAB") nil))

;; Make horizontal movement cross lines                                    
(setq-default evil-cross-lines t)

;; Setting RETURN key in org-mode to follow links
(setq org-return-follows-link  t)
(add-to-list 'evil-emacs-state-modes 'eww-mode)
(add-to-list 'evil-emacs-state-modes 'dired-mode)
(add-to-list 'evil-emacs-state-modes 'org-side-tree)
;;(add-to-list 'evil-emacs-state-modes 'elfeed-show-mode) 
;;(add-to-list 'evil-emacs-state-modes 'elfeed-search-mode) 
;;(add-to-list 'evil-emacs-state-modes 'nov-mode)
;;(add-to-list 'evil-emacs-state-modes 'wl-folder-mode)
;;(add-to-list 'evil-emacs-state-modes 'wl-summary-mode)
(add-to-list 'evil-emacs-state-modes 'mime-view-mode)
(add-to-list 'evil-emacs-state-modes 'ebib-index-mode)
(add-to-list 'evil-emacs-state-modes 'ebib-entry-mode)
```


# general keybindings

```emacs-lisp
  (defun uka/dsync ()
    (interactive)
    (shell-command (concat "cd " (my/localfile "..") " && ./bin/dsync")))

  (defun my-escesc () ;; wenn META nicht klappt:
    (interactive)
    (evil-esc-mode 1) 
    (setq evil-esc-delay 0.2))

  (my/leader-keys
    ;;"SPC" '(counsel-M-x :wk "Counsel M-x")
    "SPC" '(execute-extended-command :wk "M-x")
    "TAB" '(comment-line :wk "Comment lines")
    "#" '(my-indirect-buffer :wk "note-bar")
    "." '(find-file :wk "Find file")
    "," '(flyspell-correct-word-before-point :wk "Correct!")
    ;;"a" '((lambda()(interactive)(org-agenda nil "n")) :wk "org-agenda")
    "c" '(count-words :wk "Count words")
    "u" '(universal-argument :wk "Universal argument")
    ;;"y" '(yank-to-clipboard :wk "Yank to clipboard")
    "1" '(eyebrowse-switch-to-window-config-1 :wk "Screen 1")
    "2" '(eyebrowse-switch-to-window-config-2 :wk "Screen 2")
    "3" '(eyebrowse-switch-to-window-config-3 :wk "Screen 3")
    "4" '(eyebrowse-switch-to-window-config-4 :wk "Screen 4")

    "<left>" '(windmove-left :wk "Windmove Left")
    "<right>" '(windmove-right :wk "Windmove Right")
    "<up>" '(windmove-up :wk "Windmove Up")
    "<down>" '(windmove-down :wk "Windmove Down")

    "<" '((lambda()(interactive)(uka/check (uka/d6) (uka/d6))) :wk "roll fair")
    )

  (my/leader-keys
    "-" '(:ignore t :wk "System")
    "- -" '(uka/dsync :wk "Sync to github.com")
    "- v" '(emacs-version :wk "Emacs version")
    "- e" '(my-escesc :wk "evil esc-esc-mode on")
    "- s" '(shell :wk "Shell")
    )

(my/leader-keys
  "d" '(:ignore t :wk "Denote")    
  ;; "d d" '((lambda () (interactive) (find-file (my/localfile "org/denotes"))) :wk "list notes")
  "d n" '(denote :wk "new note")
  "d r" '(denote-rename-file :wk "rename")
  "d l" '(denote-link :wk "link")
  "d c" '(denote-link-after-creating :wk "create and link")
  "d b" '(denote-backlinks :wk "backlinks")
  "d d" '(denote-dired :wk "dired")
  "d g" '(denote-grep :wk "grep")
  )

  (my/leader-keys
    "f" '(:ignore t :wk "Files")    
    "f b" '((lambda () (interactive)
              (find-file (car org-cite-global-bibliography)))
            :wk "Open references.bib")
    "f c" '((lambda () (interactive)
              (find-file my/initfile))
            :wk "Open emacsinit.org")
    ;; "f d" '(find-grep-dired :wk "Search for string in files in DIR")
    ;; "f g" '(counsel-grep-or-swiper :wk "Search for string current file")
    ;; "f j" '(counsel-file-jump :wk "Jump to a file below current directory")
    ;; "f l" '(counsel-locate :wk "Locate a file")
    "f r" '(recentf-open-files :wk "Find recent files")
    ;;"f r" '(counsel-recentf :wk "Find recent files")
    )

  (my/leader-keys
    "j" '(:ignore t :wk "Journal")
    "j a" '(org-agenda :wk "Agenda")
    "j c" '(org-capture :wk "Capture")
    "j s" '(org-store-link :wk "Store link")
    "j t" '(org-inlinetask-insert-task :wk "Inline task")
    "j l" '(org-todo-list :wk "Todo list")
    "j j" '(org-journal-new-entry :wk "Neuer Eintrag")
    "j h" '((lambda () (interactive) (org-journal-new-entry 1)) :wk "Heute")
    )

  (my/leader-keys
    "l" '(:ignore t :wk "LLM")
    "l l" '(gptel-send :wk "send to OpenAI"))

  (my/leader-keys
    "o" '(:ignore t :wk "org-mode")
    "o t" '(org-babel-tangle :wk "org-babel-tangle")
    ;; "o n" '(org-noter :wk "org-noter")
    ;; "o s" '(org-noter-sync-current-note :wk "sync org-note")
    ;; "o b" '((lambda () (interactive)
              ;; (find-file "~/org/bibliography.org")) 
            ;; :wk "Open Bibliography.org")
    ;; "o e" '(org-encrypt-entry :wk "encrypt entry")
    ;; "o d" '(org-decrypt-entry :wk "decrypt entry")
    )

(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)

  (my/leader-keys
    "r" '(:ignore t :wk "References")
    "r +" '(bibtex-entry :wk "Bibtex - neu")
    "r c" '(bibtex-clean-entry :wk "Bibtex - clean")
    "r f" '(bibtex-reformat :wk "Bibtex - reformat")
    "r r" '(org-cite-insert :wk "cite")
    )

  (my/leader-keys
    "s" '(:ignore t :wk "Schreiben")
    "s i" '(scriv :wk "Schreib-Mode")
    "s r" '(flyspell-buffer :wk "Rechtschreibprüfung")
    "s c" '((lambda () (interactive) (flyspell-mode -1)) :wk "clear highlights")
    )

  (my/leader-keys
    "t" '(:ignore t :wk "Toggle")
    ;; "t t" '(org-side-tree :wk "org-side-tree")
    ;; "t n" '(org-side-tree-toggle-narrow-on-jump :wk "o-s-t: narrow")
    ;;"t d" '(darkroom-mode :wk "Darkroom-Mode")
    "t t" '(my/org-narrow-toggle :wk "toggle subTree narrow")
    )

  (my/leader-keys
    "w" '(:ignore t :wk "www")
    "w w" '((lambda () (interactive) (my-qweb "w")) :wk "Wikipedia")
    "w d" '((lambda () (interactive) (my-qweb "d")) :wk "DuckDuckGo")
    "w s" '((lambda () (interactive) (my-qweb "s")) :wk "Plato@Stanford")
    "w f" '(elfeed :wk "elfeed")
    )
(global-set-key (kbd "M-o") 'other-window)

;; (global-set-key (kbd "\C-t") 'eshell-toggle)
;;(define-key evil-normal-state-map (kbd "C-t") 'eshell-toggle)
;;(define-key evil-insert-state-map (kbd "C-t") 'eshell-toggle)
```

```emacs-lisp
(define-prefix-command 'my-map)
(global-set-key (kbd "\C-q") 'my-map)
(define-key my-map (kbd "\C-q") 'quoted-insert)
(define-key my-map (kbd "SPC") 'uka/loner)
```

