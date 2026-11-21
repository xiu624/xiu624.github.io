
# Content is duplicated per Locale instead of using a translation plugin

Each Event and Work exists as a separate Markdown file per Locale (`_posts/{de,en,zh}/{event,work}/`), and each page has a copy under `en/` and `zh/`. Locale is a front matter field, and listings filter on it. Labels and Menu live in `_data/{locale}/`.

We chose this over a Jekyll i18n plugin because the site is hosted on GitHub Pages, which only allows a fixed plugin set. Translations also differ in substance (for example the About biography), so a key-based scheme would fit poorly.

Consequence: adding an Event or Work means creating three files with matching names and dates, and German posts use the bare categories `event` and `work` while `en` and `zh` posts are prefixed.
