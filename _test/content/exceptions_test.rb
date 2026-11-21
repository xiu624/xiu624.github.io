require_relative "../test_helper"

# Each named Locale exception must still match reality. A stale exception fails
# here with a message that names it.
class ExceptionsTest < Minitest::Test
  def test_footer_links_to_the_german_impressum_for_every_locale
    footer = File.read(File.join(ROOT, LocaleExceptions::FOOTER_TEMPLATE), encoding: "UTF-8")
    href = LocaleExceptions::FOOTER_IMPRESSUM_HREF
    assert_includes footer, %(href="#{href}"),
                    "stale exception 'footer Impressum link': #{LocaleExceptions::FOOTER_TEMPLATE} " \
                    "no longer links to #{href}"
    refute_includes footer, "page_url_prefix",
                    "stale exception 'footer Impressum link': the footer now builds Locale-prefixed links"
  end

  def test_menu_icons_still_differ_between_locales
    types = LocaleExceptions::MENU_TYPES_THAT_MAY_DIFFER
    per_locale = LOCALES.map do |locale|
      data_file(locale, "menu").select { |item| types.include?(item["type"]) }.map { |item| item["url"] }
    end
    refute_equal 1, per_locale.uniq.size,
                 "stale exception 'menu icons may differ': every Locale now has the same #{types.join(', ')} items"
  end

  def test_the_404_page_still_links_to_every_locale
    page = LocaleExceptions::LINKS_TO_EVERY_LOCALE
    source = File.read(File.join(ROOT, page[:source]), encoding: "UTF-8")
    page[:hrefs].each do |href|
      assert_match %r{\]\(#{Regexp.escape(href)}\)}, source,
                   "stale exception '#{page[:name]}': #{page[:source]} no longer links to #{href}"
    end
  end

  def test_german_only_pages_exist_in_german_and_nowhere_else
    LocaleExceptions::GERMAN_ONLY_PAGES.each do |page|
      name = page[:name]
      source = File.join(ROOT, page[:source])
      assert File.exist?(source), "stale exception '#{name}': #{page[:source]} no longer exists"
      assert_equal "de", front_matter(source)["locale"],
                   "stale exception '#{name}': #{page[:source]} is not a German page"
      %w[en zh].each do |locale|
        copy = File.join(ROOT, locale, page[:source])
        refute File.exist?(copy),
               "stale exception '#{name}': it now exists in #{locale} (#{locale}/#{page[:source]})"
      end
    end
  end
end
