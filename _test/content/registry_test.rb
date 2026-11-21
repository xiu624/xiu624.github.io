require_relative "../test_helper"

# The feature registry rules from CONTRIBUTING.md ("Feature registry").
class RegistryTest < Minitest::Test
  STATUSES = %w[proposed specified implemented dropped].freeze
  FILENAME = /\A(\d{3})-[a-z0-9]+(-[a-z0-9]+)*\.md\z/

  def features
    Dir[File.join(ROOT, "_docs", "features", "*.md")].sort.map do |file|
      { name: File.basename(file), path: file.delete_prefix(ROOT + "/"), front: front_matter(file), text: File.read(file, encoding: "UTF-8") }
    end
  end

  # The text under a "## Heading" up to the next "## " heading, or nil if absent.
  def section(text, heading)
    body = text.sub(/\A---\s*\n.*?\n---\s*\n/m, "")
    return nil unless body =~ /^## #{Regexp.escape(heading)}[ \t]*\n(.*?)(?=^## |\z)/m
    Regexp.last_match(1).strip
  end

  def test_feature_files_are_named_with_a_three_digit_number_and_a_slug
    features.each do |feature|
      assert_match FILENAME, feature[:name], "#{feature[:path]}: name must look like 001-some-slug.md"
    end
  end

  def test_feature_numbers_are_unique
    by_number = features.group_by { |feature| feature[:name][/\A\d{3}/] }
    by_number.each do |number, list|
      assert_equal 1, list.size, "feature number #{number} is used by #{list.map { |f| f[:name] }.join(', ')}"
    end
  end

  def test_every_feature_has_a_valid_status
    features.each do |feature|
      status = feature[:front]["status"]
      assert_includes STATUSES, status, "#{feature[:path]}: status is #{status.inspect}, expected one of #{STATUSES.join(', ')}"
    end
  end

  def test_an_implemented_feature_has_an_outcome
    features.select { |f| f[:front]["status"] == "implemented" }.each do |feature|
      outcome = section(feature[:text], "Outcome")
      refute_nil outcome, "#{feature[:path]}: an implemented feature needs an Outcome section"
      refute_empty outcome.to_s, "#{feature[:path]}: the Outcome section is empty"
    end
  end

  def test_a_dropped_feature_says_why
    features.select { |f| f[:front]["status"] == "dropped" }.each do |feature|
      why = section(feature[:text], "Why dropped")
      refute_nil why, "#{feature[:path]}: a dropped feature needs a Why dropped section"
      refute_empty why.to_s, "#{feature[:path]}: the Why dropped section is empty"
    end
  end
end
