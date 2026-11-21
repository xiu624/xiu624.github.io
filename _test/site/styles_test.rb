require_relative "../test_helper"

# A typo in a utility class name must not silently remove styling.
class StylesTest < SiteTest
  UTILITY = /\A(bg|txt|col|ln|icon)-/
  # ln-img and ln-gallery are hooks for the page script (image popups), not stylesheet classes.
  SCRIPT_HOOKS = %w[ln-img ln-gallery].freeze

  def stylesheet
    sheet = built_html("index.html").at_css('link[rel~="stylesheet"][href]')["href"]
    File.read(File.join(site_dir, built_file_of(sheet, "")), encoding: "UTF-8")
  end

  def test_utility_classes_used_in_pages_exist_in_the_stylesheet
    css = stylesheet
    used = Hash.new { |hash, key| hash[key] = [] }
    built_pages.each do |path|
      built_html(path).css("[class]").each { |node| node["class"].split.each { |name| used[name] << path } }
    end
    unknown = used.keys.grep(UTILITY).reject { |name| SCRIPT_HOOKS.include?(name) }
                  .reject { |name| css =~ /\.#{Regexp.escape(name)}(?![\w-])/ }
    assert_empty unknown.map { |name| "#{name} (e.g. #{used[name].first})" },
                 "classes used in pages but missing from the stylesheet"
  end

  def test_the_script_hooks_are_still_bound_by_the_page_script
    script = built_html("index.html").css("script:not([src])").map(&:text).join("\n")
    SCRIPT_HOOKS.each do |hook|
      assert_includes script, ".#{hook}", "stale exception: the page script no longer binds .#{hook}"
    end
  end
end
