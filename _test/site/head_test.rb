require_relative "../test_helper"

# Browsers and search engines can identify every page.
class HeadTest < SiteTest
  def test_every_page_has_a_title
    built_pages.each do |path|
      title = built_html(path).at_css("head title")&.text.to_s.strip
      refute_empty title, "#{path}: the page has no title"
    end
  end

  def test_every_page_has_a_canonical_link_to_its_own_public_url
    built_pages.each do |path|
      canonical = built_html(path).at_css('link[rel="canonical"]')&.[]("href")
      assert_equal public_url(path), canonical,
                   "#{path}: canonical link is #{canonical.inspect}, expected #{public_url(path)}"
    end
  end
end
