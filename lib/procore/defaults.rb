require "procore/version"

module Procore
  # Specifies some sensible defaults for certain configurations + clients
  class Defaults
    # Default API endpoint
    API_ENDPOINT = "https://app.procore.com".freeze

    # Default User Agent header string
    USER_AGENT = "Procore Ruby Gem #{Procore::VERSION}".freeze

    # Default size to use for batch requests
    BATCH_SIZE = 500

    def self.client_options
      {
        host: Procore.configuration.host,
        user_agent: Procore.configuration.user_agent,
        default_version: Procore.configuration.default_version,
      }
    end
  end
end
