require_relative "../test_helper"

# Teaser and Portal images named in posts must exist.
class ImagesTest < Minitest::Test
  def test_every_teaser_and_portal_image_named_in_a_post_exists
    posts.each do |post|
      { "teaser_image" => post.front["teaser_image"], "portal.top_image" => post.portal["top_image"] }.each do |field, path|
        next if path.nil? || path.to_s.strip.empty?
        assert File.exist?(File.join(ROOT, path.to_s.delete_prefix("/"))),
               "#{post.path}: #{field} #{path} does not exist"
      end
    end
  end
end
