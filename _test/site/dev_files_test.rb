require_relative "../test_helper"

# Development files must not end up on the live site.
class DevFilesTest < SiteTest
  DEV_PATHS = %w[
    Gemfile Gemfile.lock Rakefile
    README.md CONTRIBUTING.md GLOSSARY.md
    _docs docs _test test
    .kiro .git
  ].freeze

  def test_development_files_are_not_published
    published = DEV_PATHS.select { |path| built?(path) }
    assert_empty published, "development files are published: #{published.join(', ')}"
  end
end
