require "procore/version"

module Procore
  # Specifies some sensible defaults for certain configurations + clients
  class Defaults
    # Default API endpoint
    API_ENDPOINT = "https://api.procore.com".freeze

    # Default Login endpoint
    LOGIN_ENDPOINT = "https://login.procore.com".freeze

    # Default User Agent header string
    USER_AGENT = "Procore Ruby Gem #{Procore::VERSION}".freeze

    # Default size to use for batch requests
    BATCH_SIZE = 500

    # Default API version to use
    DEFAULT_VERSION = "v1.0"

    def self.client_options
      {
        host: Procore.configuration.host,
        login_host: Procore.configuration.login_host,
        user_agent: Procore.configuration.user_agent,
        default_version: Procore.configuration.default_version,
      }
    end
  end
end
