# For code coverage measurements to work properly, `SimpleCov` should be loaded
# and started before any application code is loaded.
if ENV["COVERAGE"]
  require "simplecov"
  require "simplecov_json_formatter"
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::JSONFormatter
  ])

  SimpleCov.start do
    track_files "lib/**/*.{rb}"
    add_filter "test/"
  end
end

require "minitest/autorun"
require "webmock/minitest"

require "support/auth_stubs"
require "support/database"

require "procore"

Procore.configure do |config|
  config.host = "https://procore.example.com"
  config.login_host = "https://procore-login.example.com"
end
