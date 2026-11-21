require "rake/testtask"

# bundle exec rake test           everything
# bundle exec rake test:content   checks on the source files, no build
# bundle exec rake test:site      checks on the built site
namespace :test do
  Rake::TestTask.new(:content) do |t|
    t.description = "Run the source-file checks (no build)"
    t.pattern = "_test/content/**/*_test.rb"
    t.warning = false
  end

  Rake::TestTask.new(:site) do |t|
    t.description = "Run the built-site checks (builds the site once)"
    t.pattern = "_test/site/**/*_test.rb"
    t.warning = false
  end
end

desc "Run every test"
task test: ["test:content", "test:site"]

task default: :test
