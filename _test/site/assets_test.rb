require_relative "../test_helper"

# Nothing on a published page loads as a broken file. Runs offline: references
# to other hosts, such as the analytics script, are ignored and never fetched.
class AssetsTest < SiteTest
  def css_urls(css)
    css.scan(/url\(\s*['"]?([^'")]+)/).flatten.uniq.reject { |ref| external_reference?(ref) }
  end

  def references(doc)
    refs = doc.css("img[src], script[src]").map { |n| n["src"] }
    refs += doc.css('link[rel~="stylesheet"][href], link[rel~="icon"][href]').map { |n| n["href"] }
    refs += doc.css("[style]").flat_map { |n| n["style"].scan(/url\(\s*['"]?([^'")]+)/).flatten }
    refs.compact.map(&:strip).reject { |ref| ref.empty? || external_reference?(ref) }
  end

  def test_every_image_script_and_stylesheet_a_page_refers_to_exists
    missing = built_pages.flat_map do |path|
      references(built_html(path)).uniq.reject { |ref| built_file_of(ref, File.dirname(path)) }.map { |ref| "#{path} -> #{ref}" }
    end
    assert_empty missing, "references to files that do not exist:\n  #{missing.join("\n  ")}"
  end

  def test_every_file_a_stylesheet_refers_to_exists
    sheets = built_pages.flat_map { |path| built_html(path).css('link[rel~="stylesheet"][href]').map { |n| n["href"] } }.uniq
    sheets = sheets.reject { |href| external_reference?(href) }
    refute_empty sheets, "no page links a stylesheet"
    missing = sheets.flat_map do |sheet|
      file = built_file_of(sheet, "")
      next ["#{sheet} (the stylesheet itself)"] unless file
      css_urls(File.read(File.join(site_dir, file), encoding: "UTF-8"))
        .reject { |ref| built_file_of(ref, File.dirname(file)) }.map { |ref| "#{sheet} -> #{ref}" }
    end
    assert_empty missing, "stylesheet references to files that do not exist:\n  #{missing.join("\n  ")}"
  end

  def test_the_compiled_stylesheet_exists_and_is_not_empty
    sheets = built_pages.flat_map { |path| built_html(path).css('link[rel~="stylesheet"][href]').map { |n| n["href"] } }.uniq
    refute_empty sheets, "no page links a stylesheet"
    sheets.reject { |href| external_reference?(href) }.each do |sheet|
      file = built_file_of(sheet, "")
      refute_nil file, "stylesheet #{sheet} was not built"
      assert_operator File.size(File.join(site_dir, file)), :>, 0, "stylesheet #{sheet} is empty"
    end
  end
end
