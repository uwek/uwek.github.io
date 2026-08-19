---
layout: post
title:  "Mein erster Post aus Org-Mode"
date:   2026-08-18 21:00:00 +0200
categories: jekyll org
---

Dieser Beitrag wurde komplett in Org-Mode geschrieben und über
`make org` nach Markdown exportiert.

<!--more-->


# Textformatierung

Org kennt die üblichen Auszeichnungen: **fett**, *kursiv*, `code` und
sogar <del>durchgestrichen</del>.


# Liste

-   Erster Punkt
-   Zweiter Punkt
    -   Verschachtelt
-   Dritter Punkt


# Tabelle

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Werkzeug</th>
<th scope="col" class="org-left">Aufgabe</th>
</tr>
</thead>
<tbody>
<tr>
<td class="org-left">Jekyll</td>
<td class="org-left">Seiten generieren</td>
</tr>

<tr>
<td class="org-left">Org-Mode</td>
<td class="org-left">Inhalte schreiben</td>
</tr>

<tr>
<td class="org-left">Emacs</td>
<td class="org-left">Export ausführen</td>
</tr>
</tbody>
</table>


# Code-Beispiel

```ruby
def greet(name)
  puts "Hallo, #{name}!"
end
```


# Link

Mehr dazu in der [Org-Mode-Dokumentation](https://orgmode.org/).

