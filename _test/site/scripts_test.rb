require_relative "../test_helper"

# The page script binds to elements that every page must provide. The slider
# container is not required: its markup is commented out on Home.
class ScriptsTest < SiteTest
  IMAGE = /\.(jpe?g|png|gif|webp)\z/i

  def test_every_page_has_the_elements_the_page_script_binds_to
    built_pages.each do |path|
      doc = built_html(path)
      ["header", "nav.nav-toggle > li > a", "nav.nav-menu", "section", "footer"].each do |selector|
        refute_empty doc.css(selector), "#{path}: the page script binds to #{selector}, which is missing"
      end
    end
  end

  def test_image_popup_links_point_at_images_and_load_the_popup_plugin
    built_pages.each do |path|
      doc = built_html(path)
      popups = doc.css("a.ln-gallery, a.ln-img")
      next if popups.empty?
      popups.each do |link|
        assert_match IMAGE, link["href"].to_s.sub(/[#?].*\z/, ""), "#{path}: popup link #{link['href'].inspect} is not an image"
      end
      sources = doc.css("script[src]").map { |n| n["src"] }
      assert sources.any? { |src| src.include?("magnific-popup") }, "#{path}: has popup links but does not load the popup plugin"
    end
  end
end
