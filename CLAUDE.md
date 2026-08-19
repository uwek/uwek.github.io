# uwek.github.io

Persönlicher Jekyll-Blog ("Laborbuch eines Dilettanten"), deutschsprachig,
Theme Minima. Gehostet über GitHub Pages, Build läuft über GitHub Actions
(nicht den klassischen "Deploy from a branch"-Weg), weil einige verwendete
Gems (`jekyll-scholar`) nicht in der GH-Pages-Plugin-Whitelist stehen.

## Toolchain

- Ruby/Bundler/Jekyll sind über `gem install --user` in `~/.gems`
  installiert, nicht systemweit. Für jeden `bundle`/`jekyll`-Aufruf:
  ```
  export PATH="$HOME/.gems/bin:$PATH"; export GEM_HOME="$HOME/.gems"
  ```
- Lokal bauen/testen: `bundle exec jekyll build`
- Lokal servieren: `bin/srv.sh` (bindet an `0.0.0.0:4000`, damit es im LAN
  erreichbar ist — der Rechner hat keinen Browser)
- `_config.yml`-Änderungen brauchen einen Server-Neustart (kein Auto-Reload)

## Jekyll-Konfiguration, worth wissen

- `jekyll-scholar` für BibTeX-Zitate: `_bibliography/references.bib`,
  Stil `din-1505-2`, sortiert nach Autor. `{% cite key --locator N %}` für
  Inline-Zitate, `{% bibliography --cited %}` bzw. `{% bibliography %}`
  (ohne Filter) für die Literaturliste.
- `_layouts/post.html` ist überschrieben (Standard-Minima-Layout kopiert und
  erweitert): rendert die Literaturliste erst *nach* `{{ content }}` (also
  nach kramdowns automatisch ans Ende sortierten Fußnoten), und nur wenn der
  Post tatsächlich zitiert (Check auf `<li` im gerenderten Bibliography-Tag).
- Excerpts: `excerpt_separator: "<!--more-->"`, `show_excerpts: true`.
- `exclude:` in `_config.yml` enthält `bin/`, `_org/`, `_denote/`,
  `_trash/`, `Makefile` — die landen nie in `_site/`.

## Org-Mode-Publishing-Pipeline

Posts können als Org-Datei geschrieben und automatisiert nach Markdown
exportiert werden:

- Quelle: `_org/*.org` → Ziel: `_posts/*.markdown`
- `make org` konvertiert alle `_org/*.org` inkrementell (Make-Pattern-Rule)
- Eigentliche Arbeit macht `bin/org-export.el` (aufgerufen über
  `bin/org-export.sh SRC.org DEST.markdown`, `emacs --batch -Q`):
  - eigener `jekyll-md`-Backend (von `ox-md` abgeleitet)
  - Code-Blöcke werden als gefenced (` ```lang `) statt eingerückt
    exportiert, damit Rouge sie highlighted
  - `org-cite`-Zitate (`[cite:@key, p. 120f]`) werden zu
    `{% cite key --locator 120f %}` übersetzt (nicht org-cites eigenes
    CSL-Rendering — sonst müsste der Zitierstil zweimal gepflegt werden)
  - `#+print_bibliography:`/Bibliography-Output wird unterdrückt, das
    übernimmt `_layouts/post.html`
  - Babel-Auswertung ist standardmäßig blockiert (Batch-Modus kann
    `org-confirm-babel-evaluate`-Prompts nicht beantworten). Eine gezielte
    Advice auf `org-babel-expand-noweb-references` erlaubt automatische
    Auswertung **nur** für Noweb-Funktionsaufrufe (`<<name()>>`) und **nur**
    für `emacs-lisp` — alle anderen Babel-Auswertungspfade (z. B.
    `#+RESULTS:`/`#+CALL:`-Refresh) bleiben blockiert, damit ein
    literate-programming-Post mit vielen unabhängigen Codeblöcken nicht
    versehentlich real ausgeführt wird.
- Front Matter kommt aus `#+TITLE:`/`#+DATE:`/`#+CATEGORIES:` im Org-File.
- `<!--more-->` als Excerpt-Marker muss in Org über
  `#+BEGIN_EXPORT html` / `#+END_EXPORT` gesetzt werden (sonst wird es
  escaped).

## Der Emacs-Config-Post — Besonderheit

`_org/2026-08-18-emacs-init.org` ist **gleichzeitig** ein veröffentlichter
Blogpost *und* die literate-programming-Quelle für die echte, reale
Emacs-Config des Nutzers:

- `#+PROPERTY: header-args :tangle ~/.emacs.d/init.el` — beim Tangle
  landet der Code in `~/.emacs.d/init.el` (außerhalb dieses Repos!)
- Nach jeder inhaltlichen Änderung an dieser Datei: **re-tangle nötig**,
  damit die echte Config aktuell ist. Batch-Tangle mit derselben
  Noweb-Auswertungs-Erlaubnis wie beim Export:
  ```
  emacs --batch -Q --eval "
  (progn
    (require 'org) (require 'ob-core)
    (advice-add 'org-babel-expand-noweb-references :around
      (lambda (orig-fn &rest args)
        (let ((org-confirm-babel-evaluate
               (lambda (lang _body) (not (member lang (list \"emacs-lisp\" \"elisp\"))))))
          (apply orig-fn args))))
    (find-file \"_org/2026-08-18-emacs-init.org\")
    (org-babel-tangle))"
  ```
- **`* COMMENT NRU`**-Überschrift (aktuell etwa ab Zeile 500): hat keine
  schließende Sibling-Überschrift bis Dateiende — der komplette Rest der
  Datei hängt darunter und wird nie exportiert/getangelt. Ist laut Nutzer
  **Absicht** ("Steinbruch aus ausgebauten Schnipseln", geparkter/toter
  Code) — nicht versehentlich reparieren.
- Ebib-Bibliographie ist auf `_bibliography/references.bib` konfiguriert
  (`ebib-preload-bib-files`), Notizen (`<key>.org`) auf
  `_bibliography/notes/` (`ebib-notes-directory` — Default wäre sonst
  `$HOME`). BibTeX-Key-Schema: `bibtex-autokey-*` auf Autor+Jahr ohne
  Titelwörter (z. B. `schmidt2023`), `ebib-uniquify-keys t` für
  `2026a`/`2026b`-Suffixe bei Duplikaten.
- gptel nutzt OpenRouter als Backend. Wichtig:
  `gptel-make-openai` *registriert* nur ein Backend, macht es aber nicht
  automatisch aktiv — deshalb `(setq-default gptel-backend ... gptel-model
  ...)` um das tatsächlich zu setzen. API-Key liegt in `~/.authinfo`
  (Klartext, `chmod 600`, bewusste Entscheidung des Nutzers), Lookup über
  `gptel-api-key-from-auth-source`.
- `bin/dsync` (aufgerufen über `SPC - -` in der Config) committet und
  pusht automatisch alles im Repo über `bin/git-sync` — ein vom Nutzer
  selbst getriggerter Auto-Sync-Weg, unabhängig von Claude-Code-Sessions.

## Sonstiges

- `_denote/`: separate Notizen (Denote-Paket), nicht Teil des Blogs.
- `bin/bib-check.sh`: sortiert/prüft `_bibliography/references.bib` auf
  Duplikate via `bibtool`.
- Workflow in diesem Repo: Änderungen bauen (`bundle exec jekyll build`)
  und verifizieren, dann **erst nach expliziter Zustimmung** committen/
  pushen — nie automatisch pushen.
- Push von `.github/workflows/*`-Änderungen braucht ein PAT mit
  `workflow`-Scope, sonst lehnt GitHub den Push ab.
