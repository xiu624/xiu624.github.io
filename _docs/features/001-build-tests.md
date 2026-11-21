---
status: implemented
---

# Build tests

## Summary
The site has no automated tests. Add a test harness and catch up with the checks that protect what the site already promises: complete Locales, working links and assets, correct per-Locale listings, and only intended files published.

## Notes
Scope settled while grooming. The harness comes first, then the checks.

- **Harness:** Ruby with Minitest and Nokogiri, run through Rake, in `_test/` with `content/` and `site/` folders. The build goes to a temp folder. Tests are organised by what they test, not by feature. Layout and commands are described in [CONTRIBUTING.md](./../../CONTRIBUTING.md#testing). `Gemfile` gets a `:test` group declaring `rake`, `minitest` and `nokogiri`.
- **Content rules (source tree):** all the rules in `CONTRIBUTING.md` are enforced. All current content already follows them.
  - Every Event and Work exists in all three Locales with the same filename.
  - Required front matter is present, `locale` matches the folder, and the `categories` prefix is right.
  - An Event has `time`, `place` and `excerpt`. A Work leaves `time` and `place` empty.
  - Images named in `teaser_image` and `portal.top_image` exist.
  - `label.yml` has the same keys in every Locale. Menu links match across Locales.
  - Feature entries in the registry have a valid `status`, an Outcome when `implemented` and a Why dropped when `dropped`.
- **Built site:**
  - The build succeeds and each Locale has its pages.
  - Each Locale lists only its own Events and Work.
  - The homepage shows the newest Event and Work of its Locale. Newest means the `date:` front matter when set, otherwise the date in the filename, taken from the source files and not from the template's own ordering.
  - Navigation and internal links carry the right Locale Prefix, and the Locale switcher points at pages that exist.
  - Pages have a title, a canonical link and the Locale's labels.
  - The sitemap lists all pages.
  - Every referenced image, script, stylesheet and font exists.
  - The compiled stylesheet exists, and utility classes used in pages (`bg-*`, `txt-*`, `col-*`, `ln-*`, `icon-*`) exist in it.
  - Scripts referenced by pages exist, and the elements the inline script binds to are present.
- **Defects fixed here, each test first:**
  - Development files are published. `Gemfile` and `Gemfile.lock` are in the built site, because `exclude:` in `_config.yml` replaces Jekyll's defaults. The fix adds them, and the new `Rakefile`, to `exclude:`.
  - Pages render `<html>` with no `lang`. The fix is `<html lang="{{ page.locale }}">` in `_layouts/default.html`.
- **Intentional Locale differences,** kept as named exceptions in one visible place in the tests:
  - The Impressum and 404 exist in German only.
  - The footer Impressum link points to the German page in every Locale.
  - Menu icons may differ per Locale, as in `zh`. Menu links must match.
  - Everything else must match across the three Locales.
- **Out of scope:**
  - How pages look and how JavaScript behaves in a browser. These stay manual until a feature needs browser tests.
  - Fetching external URLs. Tests run offline.
  - CI. Running the tests on push becomes a later feature. Note that `.*/` in `.gitignore` hides `.github/`, so it needs an `!.github/` exception.
  - A localized Impressum.

## Outcome
The site now has a Ruby test suite, Minitest with Nokogiri, run through Rake. There are 51 tests in two groups, and the layout and commands are in the Testing section of `CONTRIBUTING.md`. `_test/content/` checks the source files without a build, and `_test/site/` checks a real build made once per run into a temp folder.

Decisions made while building it:
- Tests are central and named by area, not by feature.
- Expected values come from the source files, never from the template logic.
- Intentional Locale differences are named in `_test/locale_exceptions.rb`, and each is checked so a stale one fails with its name: the German-only Impressum and 404, the footer Impressum link, the 404 page's links to every Locale, and the Menu icons.
- `ln-img` and `ln-gallery` are script hooks, not stylesheet classes. They are left out of the stylesheet check, and a separate check confirms the page script still binds them.
- Event pages build Maps links from the place text without URL-encoding it. Browsers cope, so the tests accept it.

Behaviour changed on the published site:
- Pages declare their language, `<html lang="{{ page.locale }}">`.
- `Gemfile`, `Gemfile.lock` and `Rakefile` are no longer published.
- The 404 page is built at `/404.html`, where GitHub Pages looks for it.
- The `niudouhu` Work links to the right Event page in all three Locales.

Main files touched: `_test/`, `Rakefile`, `Gemfile`, `Gemfile.lock`, `_config.yml`, `_layouts/default.html`, `404.md`, the three `niudouhu` posts, `CONTRIBUTING.md` and `README.md`.
