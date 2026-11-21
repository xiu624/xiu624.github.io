require_relative "../test_helper"

# Interface text that comes from a Label appears in the language of the page.
class LabelsTest < SiteTest
  def test_the_menu_toggle_uses_the_menu_label_of_the_locale
    built_pages.each do |path|
      text = built_html(path).at_css("nav.nav-toggle")&.text.to_s.strip
      assert_equal labels(locale_of(path))["menu"], text, "#{path}: menu toggle text"
    end
  end

  def test_the_footer_shows_the_slogan_of_the_locale
    built_pages.each do |path|
      footer = built_html(path).at_css("footer")&.text.to_s
      assert_includes footer, labels(locale_of(path))["slogan"], "#{path}: footer slogan"
    end
  end

  def test_back_to_top_links_use_the_label_of_the_locale
    built_pages.each do |path|
      built_html(path).css('a[href="#page"]').each do |link|
        assert_equal labels(locale_of(path))["back_to_top"], link.text.strip, "#{path}: back to top link text"
      end
    end
  end

  def test_home_has_learn_more_links_to_about_event_and_work_in_the_locale_label
    LOCALES.each do |locale|
      home = home_of(locale)
      label = labels(locale)["learn_more"]
      hrefs = built_html(home).css("a").select { |a| a.text.strip == label }.map { |a| a["href"] }.sort
      assert_equal %w[about event work].map { |s| "/#{locale_dir(locale)}#{s}" }.sort, hrefs,
                   "#{home}: links labelled #{label.inspect}"
    end
  end

  def test_the_home_portal_uses_the_more_label_of_the_locale
    LOCALES.each do |locale|
      home = home_of(locale)
      jumper = built_html(home).at_css('a[href="#s1"]')
      refute_nil jumper, "#{home}: the portal has no link to the first section"
      assert_equal labels(locale)["more"], jumper.text.strip, "#{home}: portal link text"
    end
  end
end
