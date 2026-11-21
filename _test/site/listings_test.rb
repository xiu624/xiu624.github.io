require_relative "../test_helper"
require "time"

# The Event and Work listings and the Home page show the right items, in the
# right order. Expected values come from the post files, not from the templates.
class ListingsTest < SiteTest
  # The URL a post is listed under, e.g. /en/work/dahan/.
  def url_of(post)
    "/#{built_path_of(post).delete_suffix('index.html')}"
  end

  # Newest means the date: front matter when set, otherwise the date in the filename.
  def date_of(post)
    return Time.parse(post.front["date"].to_s) if post.front["date"]
    Time.parse(File.basename(post.path)[/\A\d{4}-\d{2}-\d{2}/])
  end

  def listing_path(locale, kind)
    "#{locale_dir(locale)}#{kind}/index.html"
  end

  def tiles(path)
    built_html(path).css("article.content-tile").map do |tile|
      { href: tile.at_css("a.img-teaser, a.ln-img")["href"], title: tile.at_css(".content-tile-title").text.strip }
    end
  end

  def test_each_listing_shows_exactly_the_items_of_its_locale
    LOCALES.each do |locale|
      KINDS.each do |kind|
        expected = posts.select { |p| p.locale == locale && p.kind == kind }
        shown = tiles(listing_path(locale, kind))
        assert_equal expected.map { |p| url_of(p) }.sort, shown.map { |t| t[:href] }.sort,
                     "#{locale} #{kind} listing shows the wrong items"
      end
    end
  end

  def test_listing_titles_are_the_titles_of_the_posts_in_that_locale
    LOCALES.each do |locale|
      KINDS.each do |kind|
        by_url = posts.select { |p| p.locale == locale && p.kind == kind }.to_h { |p| [url_of(p), p.front["title"]] }
        tiles(listing_path(locale, kind)).each do |tile|
          assert_equal by_url[tile[:href]], tile[:title], "#{locale} #{kind} listing: title of #{tile[:href]}"
        end
      end
    end
  end

  def test_listings_show_the_newest_item_first
    LOCALES.each do |locale|
      KINDS.each do |kind|
        by_url = posts.select { |p| p.locale == locale && p.kind == kind }.to_h { |p| [url_of(p), date_of(p)] }
        dates = tiles(listing_path(locale, kind)).map { |t| by_url[t[:href]] }
        refute_includes dates, nil, "#{locale} #{kind} listing contains items that are not #{locale} #{kind} posts"
        assert_equal dates.sort.reverse, dates, "#{locale} #{kind} listing is not ordered newest first"
      end
    end
  end

  def test_home_shows_the_newest_event_and_work_of_its_locale
    LOCALES.each do |locale|
      shown = tiles(home_of(locale)).map { |t| t[:href] }
      KINDS.each do |kind|
        newest = posts.select { |p| p.locale == locale && p.kind == kind }.max_by { |p| date_of(p) }
        assert_includes shown, url_of(newest), "#{locale} Home does not show the newest #{kind} (#{url_of(newest)})"
      end
      assert_equal KINDS.size, shown.size, "#{locale} Home should show one Event and one Work, shows #{shown.inspect}"
    end
  end
end
