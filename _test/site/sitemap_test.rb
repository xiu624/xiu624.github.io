require_relative "../test_helper"

# The sitemap lists every content page, so search engines can discover all of it.
class SitemapTest < SiteTest
  def test_the_sitemap_lists_every_content_page
    skip_error_page = LocaleExceptions::LINKS_TO_EVERY_LOCALE[:built] # the 404 page is not content
    assert built?("sitemap.xml"), "the build produced no sitemap.xml"
    listed = Nokogiri::XML(File.read(File.join(site_dir, "sitemap.xml"))).remove_namespaces!.css("url loc").map { |n| n.text.strip }
    expected = (expected_pages - [skip_error_page]).map { |path| public_url(path) }
    missing = expected - listed
    assert_empty missing, "pages missing from the sitemap:\n  #{missing.join("\n  ")}"
  end
end
