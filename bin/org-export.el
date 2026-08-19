;;; org-export.el --- Export a single Org file to a Jekyll post -*- lexical-binding: t; -*-

;; Usage: emacs --batch -Q --load bin/org-export.el SRC.org DEST.markdown
;;
;; Reads #+TITLE:, #+DATE: and #+CATEGORIES: from the Org file and
;; writes a Jekyll post with YAML front matter, body exported via a
;; Markdown backend derived from ox-md that
;;
;; - renders source blocks as fenced code blocks (```lang ... ```)
;;   instead of ox-md's default 4-space-indented code, so Rouge can
;;   syntax-highlight them;
;; - translates org-cite citations, e.g. [cite:@wagner2022, p. 120f],
;;   into jekyll-scholar Liquid tags, e.g. {% cite wagner2022 --locator
;;   120f %}, instead of leaving citation rendering to org-cite (which
;;   would need its own CSL setup independent of jekyll-scholar's);
;; - drops #+print_bibliography: output, since the post layout already
;;   renders the bibliography via {% bibliography --cited %}.
;;
;; Babel evaluation: Org's export machinery walks the whole buffer and
;; may want to (re-)run any #+RESULTS:/#+CALL: it finds, gated by
;; `org-confirm-babel-evaluate' -- which defaults to an interactive
;; y-or-n-p that just aborts under --batch. We don't want to lift that
;; gate wholesale (a literate-programming post can contain many
;; unrelated code blocks that would then execute for real under a bare
;; -Q Emacs with no packages loaded). But noweb function-call
;; references, e.g. "<<name()>>", are a deliberate per-reference
;; request by the author to inline a block's *evaluated* result, so we
;; scope permission narrowly: only calls going through
;; `org-babel-expand-noweb-references' (the noweb-reference resolver)
;; get to auto-evaluate, and only for emacs-lisp. Every other
;; evaluation path (plain #+RESULTS:/#+CALL: refresh) keeps the
;; default, safe "ask and abort" behavior.

(require 'ox-md)
(require 'oc)
(require 'ob-core)

(advice-add 'org-babel-expand-noweb-references :around
  (lambda (orig-fn &rest args)
    (let ((org-confirm-babel-evaluate
           (lambda (lang _body) (not (member lang '("emacs-lisp" "elisp"))))))
      (apply orig-fn args))))

(defun jekyll-org--src-block (src-block _contents info)
  (let ((lang (org-element-property :language src-block))
        (code (org-export-format-code-default src-block info)))
    (format "```%s\n%s```\n" (or lang "") code)))

(defun jekyll-org--locator-from-suffix (suffix)
  "Turn an org-cite reference SUFFIX secondary-string into a bare
jekyll-scholar --locator value, e.g. \", p. 120f\" -> \"120f\"."
  (when suffix
    (let ((text (string-trim (org-element-interpret-data suffix))))
      (setq text (replace-regexp-in-string "\\`[,;:]+\\s-*" "" text))
      (setq text (replace-regexp-in-string "\\`\\(?:pp?\\.\\|[Ss]\\.\\)\\s-*" "" text))
      (unless (string-empty-p text) text))))

(defun jekyll-org--citation (citation _contents _info)
  (let* ((refs     (org-cite-get-references citation))
         (keys     (mapcar (lambda (r) (org-element-property :key r)) refs))
         (locators (delq nil
                          (mapcar (lambda (r)
                                    (jekyll-org--locator-from-suffix
                                     (org-element-property :suffix r)))
                                  refs)))
         (style    (or (org-element-property :style citation) ""))
         (opts     (concat
                    (mapconcat (lambda (loc) (format " --locator %s" loc)) locators "")
                    (when (string-match-p "\\`\\(?:na\\|noauthor\\)\\'" style)
                      " --suppress_author"))))
    (format "{%% cite %s%s %%}" (mapconcat #'identity keys " ") opts)))

(defun jekyll-org--bibliography (&rest _)
  "Bibliography is rendered by the post layout via jekyll-scholar; drop it here."
  "")

(org-export-define-derived-backend 'jekyll-md 'md
  :translate-alist '((src-block . jekyll-org--src-block)
                      (citation . jekyll-org--citation)
                      (bibliography . jekyll-org--bibliography)))

(let* ((src  (nth 0 command-line-args-left))
       (dest (and (nth 1 command-line-args-left)
                  (expand-file-name (nth 1 command-line-args-left)))))
  (unless (and src dest)
    (error "Usage: emacs --batch -Q --load org-export.el SRC.org DEST.markdown"))

  (find-file src)

  (let* ((kw         (org-collect-keywords '("TITLE" "DATE" "CATEGORIES")))
         (title      (car (cdr (assoc "TITLE" kw))))
         (date       (car (cdr (assoc "DATE" kw))))
         (categories (car (cdr (assoc "CATEGORIES" kw))))
         ;; :with-cite-processors nil keeps org-cite from pre-rendering
         ;; citations via its own export processor, so our own
         ;; `citation' transcoder in the jekyll-md backend gets to run.
         (body       (org-export-as 'jekyll-md nil nil t
                                     '(:with-toc nil :with-cite-processors nil))))

    (with-temp-file dest
      (insert "---\n")
      (insert "layout: post\n")
      (insert (format "title:  %S\n" (or title "Untitled")))
      (when date (insert (format "date:   %s\n" date)))
      (when categories (insert (format "categories: %s\n" categories)))
      (insert "---\n\n")
      (insert body))))
