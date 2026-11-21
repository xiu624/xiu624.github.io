require "minitest/autorun"
require "open3"
require "tmpdir"
require "fileutils"
require "yaml"
require "nokogiri"

require_relative "locale_exceptions"

ROOT = File.expand_path("..", __dir__)
LOCALES = %w[de en zh].freeze
KINDS = %w[event work].freeze
SITE_URL = YAML.safe_load_file(File.join(ROOT, "_config.yml"))["url"].to_s.chomp("/").freeze

# Every post (Event or Work) in every Locale, with its parsed front matter.
Post = Struct.new(:path, :locale, :kind, :front) do
  # The portal: block of the front matter, or {} when it is missing or not a hash.
  def portal
    front["portal"].is_a?(Hash) ? front["portal"] : {}
  end
end

# Readers for the source files, available in every test.
module SourceFiles
  # Reads the YAML front matter of a source file. Returns {} when there is none.
  def front_matter(path)
    text = File.read(path, encoding: "UTF-8")
    return {} unless text =~ /\A---\s*\n(.*?)\n---/m
    YAML.safe_load(Regexp.last_match(1), aliases: true, permitted_classes: [Date, Time]) || {}
  end

  def posts
    Dir[File.join(ROOT, "_posts", "*", "*", "*.md")].sort.map do |file|
      locale, kind = file.delete_prefix(File.join(ROOT, "_posts") + "/").split("/")
      Post.new(file.delete_prefix(ROOT + "/"), locale, kind, front_matter(file))
    end
  end

  # A per-Locale data file such as label or menu. Menu URLs use :prefix, which YAML reads as a Symbol.
  def data_file(locale, name)
    YAML.safe_load_file(File.join(ROOT, "_data", locale, "#{name}.yml"), permitted_classes: [Symbol])
  end

  def labels(locale)
    data_file(locale, "label")
  end
end

Minitest::Test.include(SourceFiles)

# Builds the site into a temporary folder, once per run, on first use.
# The normal build output (_site/) is never touched.
module SiteBuild
  def self.dir
    @dir ||= build!
  end

  def self.build!
    dest = Dir.mktmpdir("site-test-")
    Minitest.after_run { FileUtils.remove_entry(dest) if File.directory?(dest) }
    output, status = Open3.capture2e(
      "bundle", "exec", "jekyll", "build", "--destination", dest, "--quiet", chdir: ROOT
    )
    raise "jekyll build failed:\n#{output}" unless status.success?
    dest
  end
end

# Base class for tests on the built site.
class SiteTest < Minitest::Test
  SECTION_PAGES = %w[index.html about/index.html event/index.html work/index.html].freeze

  def site_dir
    SiteBuild.dir
  end

  def built?(path)
    File.exist?(File.join(site_dir, path))
  end

  # Every built HTML page, as a path relative to the built site.
  def built_pages
    Dir[File.join(site_dir, "**", "*.html")].map { |file| file.delete_prefix(site_dir + "/") }.sort
  end

  # The Locale a built page belongs to: English and Chinese pages live under
  # /en and /zh, everything else is German.
  def locale_of(path)
    first = path.split("/").first
    %w[en zh].include?(first) ? first : "de"
  end

  # A built page, parsed.
  def built_html(path)
    Nokogiri::HTML(File.read(File.join(site_dir, path), encoding: "UTF-8"))
  end

  # "" for German, "en/" or "zh/" for the others.
  def locale_dir(locale)
    locale == "de" ? "" : "#{locale}/"
  end

  def home_of(locale)
    "#{locale_dir(locale)}index.html"
  end

  # Where the built page of a post should be, derived from its file name.
  def built_path_of(post)
    slug = File.basename(post.path, ".md").sub(/\A\d{4}-\d{2}-\d{2}-/, "")
    "#{locale_dir(post.locale)}#{post.kind}/#{slug}/index.html"
  end

  # Every page the site should have, derived from the source files and the named exceptions.
  def expected_pages
    section = LOCALES.flat_map { |locale| SECTION_PAGES.map { |page| "#{locale_dir(locale)}#{page}" } }
    german_only = LocaleExceptions::GERMAN_ONLY_PAGES.map { |page| page[:built] }
    (section + posts.map { |post| built_path_of(post) } + german_only).sort
  end

  # True for references that are not files of this site: other hosts and data: URIs.
  def external_reference?(ref)
    ref.start_with?("http://", "https://", "//", "data:", "mailto:")
  end

  # The built file a reference points to, from a page or a stylesheet, or nil.
  # Absolute references start at the site root. Relative ones start at the referring folder.
  # With as_page: true, "/en/about" and "/en/about/" also find en/about/index.html.
  def built_file_of(ref, from_dir, as_page: false)
    clean = ref.sub(/[#?].*\z/, "")
    relative = clean.start_with?("/") ? clean.delete_prefix("/") : File.join(from_dir, clean)
    normalized = File.expand_path(relative, "/").delete_prefix("/")
    candidates = [normalized]
    candidates += ["#{normalized}/index.html".delete_prefix("/"), "#{normalized}.html"] if as_page
    candidates.find { |candidate| !candidate.empty? && File.file?(File.join(site_dir, candidate)) }
  end

  # The public URL of a built page, from the configured site URL.
  def public_url(path)
    "#{SITE_URL}/#{path.sub(/index\.html\z/, '')}"
  end
end
