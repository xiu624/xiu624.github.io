# Intentional differences between Locales. Every Locale rule in the tests allows
# exactly these and nothing else. _test/content/exceptions_test.rb fails when an
# exception no longer matches reality, so this list cannot go stale unnoticed.
module LocaleExceptions
  # Pages that exist in German only.
  GERMAN_ONLY_PAGES = [
    { name: "Impressum", source: "impressum/index.md", built: "impressum/index.html" },
    { name: "404", source: "404.md", built: "404.html" }
  ].freeze

  # The footer shows the same link to the German Impressum in every Locale.
  FOOTER_TEMPLATE = "_includes/footer.html".freeze
  FOOTER_IMPRESSUM_HREF = "/impressum".freeze

  # The 404 page is German but deliberately links to the English and Chinese
  # Home pages, so its links are not held to the "stay in your Locale" rule.
  LINKS_TO_EVERY_LOCALE = {
    name: "404 page links to every Locale",
    source: "404.md",
    built: "404.html",
    hrefs: ["/en", "/zh"]
  }.freeze

  # Menu items of these types may differ per Locale (the Chinese Menu shows a
  # WeChat code instead of Facebook and YouTube). Menu links must still match.
  MENU_TYPES_THAT_MAY_DIFFER = %w[icon].freeze
end
