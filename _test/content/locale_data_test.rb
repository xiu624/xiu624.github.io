require_relative "../test_helper"

# Labels and Menu are defined once per Locale and must stay in step.
class LocaleDataTest < Minitest::Test
  def test_every_locale_defines_the_same_labels
    keys = LOCALES.to_h { |locale| [locale, labels(locale).keys.sort] }
    all = keys.values.flatten.uniq.sort
    LOCALES.each do |locale|
      missing = all - keys[locale]
      assert_empty missing, "_data/#{locale}/label.yml: missing labels #{missing.join(', ')}"
    end
  end

  def test_menu_links_match_across_locales
    # Menu items of the types listed as exceptions (icons) may differ per Locale.
    comparable = lambda do |locale|
      data_file(locale, "menu")
        .reject { |item| LocaleExceptions::MENU_TYPES_THAT_MAY_DIFFER.include?(item["type"]) }
        .map { |item| [item["type"], item["url"], item["target"], item["class"]] }
    end
    reference = comparable.call("de")
    %w[en zh].each do |locale|
      assert_equal reference, comparable.call(locale),
                   "_data/#{locale}/menu.yml: menu links differ from the German menu"
    end
  end
end
