require_relative "../test_helper"

class ContentSmokeTest < Minitest::Test
  def test_post_folders_exist_for_every_locale_and_kind
    LOCALES.each do |locale|
      KINDS.each do |kind|
        dir = File.join(ROOT, "_posts", locale, kind)
        assert Dir.exist?(dir), "missing post folder _posts/#{locale}/#{kind}"
      end
    end
  end
end
