require "minitest/autorun"
require "webmock/minitest"

require "support/auth_stubs"
require "support/database"

require "procore"

Procore.configure do |config|
  config.host = "https://procore.example.com"
  config.default_version = "v1.0"
end
