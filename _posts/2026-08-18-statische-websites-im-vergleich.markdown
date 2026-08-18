---
layout: post
title:  "Warum eigentlich ein statischer Blog?"
date:   2026-08-18 09:00:00 +0200
categories: jekyll
---

Statische Site-Generatoren wie Jekyll erfreuen sich seit Jahren stabiler Beliebtheit,
gerade für kleinere, persönliche Blogs. Ein häufig genannter Vorteil ist die
Geschwindigkeit: da bei jedem Aufruf keine Datenbankabfrage nötig ist, sondern
fertige HTML-Dateien ausgeliefert werden, lassen sich statische Seiten laut
{% cite schmidt2023 %} im Schnitt drei- bis fünfmal schneller ausliefern als
klassische, serverseitig gerenderte CMS-Systeme.[^1]

<!--more-->

Für den Einstieg lohnt sich ein Blick auf die grundlegenden Konzepte von Jekyll –
Layouts, Includes und die Trennung von Inhalt und Darstellung werden unter anderem
ausführlich in {% cite keller2021 %} beschrieben, einem Standardwerk für Jekyll-Neulinge.[^2]

Ein weiterer Aspekt ist die Auslieferung selbst: {% cite wagner2022 --locator 120f %} und {% cite wagner2022 --locator 140f %} zeigen, dass
sich die Ladezeit generierter Websites durch konsequentes Caching und minimierte
Assets noch einmal deutlich senken lässt, unabhängig vom verwendeten Generator.

Auch das Werkzeug drumherum lässt sich anpassen: wer Beiträge in Emacs schreibt,
kann sich eine kleine Funktion definieren, die ein neues Post-Grundgerüst anlegt:

```elisp
(defun jekyll-new-post (title)
  "Create a new Jekyll post skeleton in _posts/."
  (interactive "sTitle: ")
  (let* ((slug (replace-regexp-in-string "[^a-z0-9]+" "-" (downcase title)))
         (filename (format "_posts/%s-%s.markdown"
                           (format-time-string "%Y-%m-%d")
                           slug)))
    (find-file filename)
    (insert (format "---\nlayout: post\ntitle: \"%s\"\ndate: %s\n---\n\n"
                    title
                    (format-time-string "%Y-%m-%d %H:%M:%S %z")))))
```

Genug Theorie – als Nächstes geht es hier im Blog um die konkrete Umsetzung.

[^1]: Gemessen wurde die Time-to-First-Byte bei identischer Serverhardware, ohne CDN-Beschleunigung – mit CDN relativiert sich der Unterschied deutlich.
[^2]: Es existiert mittlerweile auch eine überarbeitete zweite Auflage, die stärker auf Jekyll 4 eingeht.
