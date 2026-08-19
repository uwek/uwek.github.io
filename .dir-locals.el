;; Per-directory Emacs settings for this repo.
;; Opening `ebib' (M-x ebib) anywhere inside this project automatically
;; loads _bibliography/references.bib.

((nil . ((eval . (setq-local ebib-preload-bib-files
                              (list (expand-file-name "_bibliography/references.bib"
                                                       (locate-dominating-file
                                                        default-directory ".dir-locals.el"))))))))
