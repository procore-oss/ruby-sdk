# For code coverage measurements to work properly, `SimpleCov` should be loaded
# and started before any application code is loaded.
if ENV["COVERAGE"]
  require "simplecov"
  require "simplecov_json_formatter"
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::JSONFormatter])
  SimpleCov.start do
    add_filter "/test/"
  end
  SimpleCov.command_name "Unit Tests"
end

require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ["--display-cop-names"]
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.warning = false
end

task default: [:rubocop, :test]
