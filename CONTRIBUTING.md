# Contributing

Read [GLOSSARY.md](./GLOSSARY.md) first. Terms such as Event, Work, Locale and Portal are used here as defined there. "Post" only means the Jekyll file type; Event and Work are the domain terms. Design decisions are in [_docs/adr](./_docs/adr). Coding tasks are tracked in [_docs/tasks](./_docs/tasks).

## Stack

- Jekyll on GitHub Pages (`github-pages` gem, `jekyll-sitemap`). Only whitelisted plugins work.
- jQuery with vendored plugins, SCSS with Bourbon and Neat, and a custom icon font (`font-prims`).
- No build tooling, linter or formatter. `_site/`, `.sass-cache/` and `.DS_Store` are gitignored.

## Adding an Event or Work

Create one file per Locale with the same filename:

```
_posts/{de,en,zh}/{event,work}/YYYY-MM-DD-slug.md
```

- The slug is lowercase kebab-case (pinyin for Chinese titles, e.g. `chunfen`).
- Front matter always has `layout: post`, `locale`, `categories`, `title`, `teaser_image`, `excerpt`, `time`, `place`, `side_content` and a `portal:` block (`top_text`, `top_image`).
- Add `show_on_homepage: true` under `portal:` to make an Event a Featured Event.
- A Work leaves `time` and `place` empty.
- `side_content` is an inline HTML string with escaped quotes, usually the poster `<img>`.
- Categories: German uses the bare `event` or `work`. English and Chinese prefix the Locale: `en event`, `zh work`.
- Images go in `/images/{event|work}/<date-or-slug>/`: `portal.jpg`, `teaser.jpg`, and for Events `poster.jpg` and `live-photo-NN.jpg`.

Body markup:

- Video: `<figure class="video-container">` with a YouTube iframe.
- Gallery: `<figure class="col-two">` containing `<a class="ln-gallery">` links.
- Note: an inline `<i class="icon-note icon-inline"></i>`, with `{:#id .notice .bg-light}` on the next line.

## Pages

- The German page lives at the root (`about/index.md`). English and Chinese copies live under `en/` and `zh/`.
- Page copy is HTML strings in front matter under a page-named key (`about:`, `home:`, `event:`, `work:`).
- Markdown inside HTML wrappers needs `<div markdown="1">`.
- Labels and Menu live in `_data/{de,en,zh}/label.yml` and `menu.yml`. Menu URLs use the `:prefix` token, which the header replaces with the Locale Prefix.

## Templates (Liquid)

- A layout declares `layout: default` and its `portal:` options (`top`, `bottom` and the CSS classes per band). Pages only provide content.
- Call `{% include variables.html %}` at the top of any template that needs `page_url_prefix`. Build internal links as `{{ page_url_prefix }}/path`.
- Read UI text from `site.data[page.locale].label.*`. Never hard-code it.
- Listings use `post-list.html` with `posts=site.categories.X locale=page.locale`, plus `first=true` for the latest item.
- Indent with 4 spaces in HTML, SCSS and YAML.

## SCSS

- Styles are in `css/main.scss`, which starts with empty front matter (`---`). Partials are in `_sass/`.
- Variables are flat and aligned in `_sass/_variables.scss` (`$red`, `$blue-light`, `$base-font-size`).
- Utility class prefixes: `bg-*` (background), `txt-*` (text colour), `col-*` (grid: `two`, `three`, `four`, `two-one`), `ln-*` (link behaviour: `ln-mono`, `ln-img`, `ln-gallery`) and `icon-*`.
- Combine utilities in layout or page front matter, e.g. `"txt-white bg-green header-emphasis"`.
- Mixins: `font-smoothing` and `ln-mono($color, $hover-color)`.

## JavaScript

- jQuery only. Page code is inline at the bottom of `_layouts/default.html`. Libraries are vendored in `js/vendor/`. No modules or bundler.
- Style: `var`, `$(document).ready`, short `//` comments starting with "enable …".

## Git

- Manual commits: `UPDATE: <sentence>.`
- Dependency bumps from Dependabot keep their default message.
