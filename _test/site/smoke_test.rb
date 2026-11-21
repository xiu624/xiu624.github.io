require_relative "../test_helper"

class SiteSmokeTest < SiteTest
  def test_home_is_built_for_every_locale
    LOCALES.each do |locale|
      path = home_of(locale)
      assert built?(path), "Home for #{locale} was not built (expected #{path})"
    end
  end
end
