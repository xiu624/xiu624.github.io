require_relative "../test_helper"

# Visitors stay in their language when following links, and the Locale switcher
# never leads to a missing page. Everything runs offline: external URLs are
# only checked for form, never fetched.
class LinksTest < SiteTest
  SWITCHER_ICON = "i[class*=icon-lang-]".freeze

  # The built file an absolute internal link leads to, such as "/en/about" or "/css/main.css", or nil.
  def built_file_for(href)
    built_file_of(href, "", as_page: true)
  end

  def internal?(href)
    href.start_with?("/") && !href.start_with?("//")
  end

  # Normal links of a page, without the Locale switcher.
  def links(path)
    built_html(path).css("a[href]").reject { |a| a.at_css(SWITCHER_ICON) }.map { |a| a["href"].to_s.strip }
  end

  def exempt_from_locale_rule?(from_page, href)
    return true if from_page == LocaleExceptions::LINKS_TO_EVERY_LOCALE[:built]
    href.sub(/[#?].*\z/, "").chomp("/") == LocaleExceptions::FOOTER_IMPRESSUM_HREF
  end

  def test_internal_links_resolve_to_a_built_file
    broken = built_pages.flat_map do |from|
      links(from).select { |href| internal?(href) && built_file_for(href).nil? }.map { |href| "#{from} -> #{href}" }
    end
    assert_empty broken, "internal links that lead nowhere:\n  #{broken.join("\n  ")}"
  end

  def test_internal_links_stay_in_the_locale_of_their_page
    built_pages.each do |from|
      links(from).select { |href| internal?(href) }.each do |href|
        next if exempt_from_locale_rule?(from, href)
        target = built_file_for(href)
        next if target.nil? || !target.end_with?(".html") # broken links are reported by another test
        assert_equal locale_of(from), locale_of(target),
                     "#{from} (#{locale_of(from)}): link #{href} leads to a #{locale_of(target)} page"
      end
    end
  end

  def test_german_links_carry_no_locale_prefix_and_others_carry_theirs
    built_pages.each do |from|
      links(from).select { |href| internal?(href) }.each do |href|
        next if exempt_from_locale_rule?(from, href)
        path = href.sub(/[#?].*\z/, "")
        next unless built_file_for(href).to_s.end_with?(".html")
        prefixed = path =~ %r{\A/(en|zh)(/|\z)}
        if locale_of(from) == "de"
          refute prefixed, "#{from}: German page links to #{href}, which carries a Locale prefix"
        else
          assert_match %r{\A/#{locale_of(from)}(/|\z)}, path, "#{from}: link #{href} is missing the /#{locale_of(from)} prefix"
        end
      end
    end
  end

  def test_external_and_mail_links_are_well_formed
    built_pages.each do |from|
      links(from).reject { |href| internal?(href) || href.start_with?("#") }.each do |href|
        if href.start_with?("mailto:")
          assert_match(/\Amailto:[^@\s]+@[^@\s]+\z/, href, "#{from}: malformed mail link #{href}")
        else
          # Scheme and host must be there. Spaces in the path are tolerated: the
          # Event and Work pages build Maps links from the place text, and browsers encode them.
          assert_match %r{\A(https?:)?//[^/\s?#]+}, href, "#{from}: malformed external link #{href}"
        end
      end
    end
  end

  def test_the_locale_switcher_leads_to_an_existing_page_in_each_other_locale
    switchers = 0
    built_pages.each do |from|
      anchors = built_html(from).css("a[href]").select { |a| a.at_css(SWITCHER_ICON) }
      next if anchors.empty?
      switchers += 1
      targets = anchors.to_h { |a| [a.at_css(SWITCHER_ICON)["class"][/icon-lang-(\w+)/, 1], a["href"]] }
      assert_equal (LOCALES - [locale_of(from)]).sort, targets.keys.sort,
                   "#{from}: the switcher should offer exactly the other Locales"
      targets.each do |locale, href|
        file = built_file_for(href)
        refute_nil file, "#{from}: the switcher link to #{locale} (#{href}) leads nowhere"
        assert_equal locale, locale_of(file), "#{from}: the switcher link to #{locale} (#{href}) lands in #{locale_of(file)}"
      end
    end
    assert_operator switchers, :>, 0, "no page has a Locale switcher"
  end
end
