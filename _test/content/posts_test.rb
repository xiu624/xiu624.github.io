require_relative "../test_helper"

# The post rules from CONTRIBUTING.md ("Adding an Event or Work").
class PostsTest < Minitest::Test
  REQUIRED_KEYS = %w[layout locale categories title teaser_image excerpt time place side_content portal].freeze

  def blank?(value)
    value.nil? || value.to_s.strip.empty?
  end

  def test_every_event_and_work_exists_in_all_locales_with_the_same_filename
    KINDS.each do |kind|
      names = LOCALES.to_h do |locale|
        dir = File.join(ROOT, "_posts", locale, kind)
        [locale, Dir.exist?(dir) ? Dir.children(dir).select { |f| f.end_with?(".md") }.sort : []]
      end
      all = names.values.flatten.uniq.sort
      LOCALES.each do |locale|
        missing = all - names[locale]
        assert_empty missing, "#{kind}: missing in #{locale}: #{missing.join(', ')}"
      end
    end
  end

  def test_every_post_has_its_required_front_matter
    posts.each do |post|
      missing = REQUIRED_KEYS.reject { |key| post.front.key?(key) }
      assert_empty missing, "#{post.path}: missing front matter #{missing.join(', ')}"
      assert_equal "post", post.front["layout"], "#{post.path}: layout must be post"
      refute blank?(post.front["title"]), "#{post.path}: title is blank"
      refute blank?(post.front["teaser_image"]), "#{post.path}: teaser_image is blank"
      %w[top_text top_image].each do |key|
        assert post.portal.key?(key), "#{post.path}: missing portal.#{key}"
      end
    end
  end

  def test_each_posts_locale_matches_its_folder
    posts.each do |post|
      assert_equal post.locale, post.front["locale"],
                   "#{post.path}: locale is #{post.front['locale'].inspect}, expected #{post.locale.inspect}"
    end
  end

  def test_categories_carry_the_locale_prefix_except_for_german
    posts.each do |post|
      expected = post.locale == "de" ? post.kind : "#{post.locale} #{post.kind}"
      assert_equal expected, post.front["categories"],
                   "#{post.path}: categories is #{post.front['categories'].inspect}, expected #{expected.inspect}"
    end
  end

  def test_every_event_has_time_place_and_excerpt
    posts.select { |post| post.kind == "event" }.each do |post|
      %w[time place excerpt].each do |key|
        refute blank?(post.front[key]), "#{post.path}: an Event needs #{key}"
      end
    end
  end

  def test_every_work_leaves_time_and_place_empty
    posts.select { |post| post.kind == "work" }.each do |post|
      %w[time place].each do |key|
        assert blank?(post.front[key]), "#{post.path}: a Work must leave #{key} empty, found #{post.front[key].inspect}"
      end
    end
  end
end
