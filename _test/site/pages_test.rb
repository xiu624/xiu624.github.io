require_relative "../test_helper"

# Every Locale has the full set of pages. Expected pages come from the source
# files and from the named exceptions, never from the templates.
class PagesTest < SiteTest
  def test_the_site_builds
    refute_empty built_pages, "the build produced no pages"
  end

  def test_every_locale_has_home_about_event_and_work_pages
    LOCALES.each do |locale|
      SECTION_PAGES.each do |page|
        path = "#{locale_dir(locale)}#{page}"
        assert built?(path), "#{locale}: missing page #{path}"
      end
    end
  end

  def test_every_event_and_work_has_its_own_page_in_each_locale
    posts.each do |post|
      path = built_path_of(post)
      assert built?(path), "#{post.path}: its page #{path} was not built"
    end
  end

  def test_the_german_only_pages_are_built_in_german
    LocaleExceptions::GERMAN_ONLY_PAGES.each do |page|
      assert built?(page[:built]), "#{page[:name]}: expected #{page[:built]} to be built"
    end
  end

  def test_no_page_is_built_without_a_matching_source
    unexpected = built_pages - expected_pages
    assert_empty unexpected, "pages built without a matching source: #{unexpected.join(', ')}"
  end
end
