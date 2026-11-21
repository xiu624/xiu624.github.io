# Prims Studio website

Public website of Prims Studio, a Munich-based music studio. A Jekyll site hosted on GitHub Pages, published in German (default), English and Chinese.

## Start here

- [GLOSSARY.md](./GLOSSARY.md): the domain vocabulary (Event, Work, Locale, Portal, ...). Use these terms in code, docs and commits.
- [CONTRIBUTING.md](./CONTRIBUTING.md): coding conventions for content files, Liquid templates, SCSS and JavaScript.
- [_docs/adr](./_docs/adr): architecture decisions and why they were made.
- [_docs/features](./_docs/features): the registry of features, from proposed to implemented.

## Run locally

```
bundle install
bundle exec jekyll serve
```

The site is served at http://localhost:4000. Run the tests with `bundle exec rake test`. There is no linter or formatter. Look at how pages render in all three Locales yourself, as the tests don't check looks or JavaScript.

## Rules that matter most

- Every Event or Work needs one file per Locale (`de`, `en`, `zh`) with the same filename.
- Build internal links with `{{ page_url_prefix }}`, and read UI text from `site.data[page.locale].label.*`.
- Only whitelisted GitHub Pages plugins work.
- Commit messages: `UPDATE: <sentence>.`
- Folders starting with `_` are not published. Root files without front matter are.
