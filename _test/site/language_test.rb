require_relative "../test_helper"

# Every page declares the language of its Locale.
class LanguageTest < SiteTest
  def test_every_page_declares_the_language_of_its_locale
    refute_empty built_pages, "the build produced no pages"
    built_pages.each do |path|
      lang = built_html(path).at_css("html")["lang"]
      assert_equal locale_of(path), lang,
                   "#{path}: <html lang> is #{lang.inspect}, expected #{locale_of(path).inspect}"
    end
  end
end
