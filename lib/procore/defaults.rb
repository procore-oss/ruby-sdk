require "procore/version"

module Procore
  # Specifies some sensible defaults for certain configurations + clients
  class Defaults
    # Default API endpoint
    API_ENDPOINT = "https://app.procore.com".freeze

    # Default authentication endpoint
    AUTH_HOST = "https://login.procore.com".freeze

    # Default User Agent header string
    USER_AGENT = "Procore Ruby Gem #{Procore::VERSION}".freeze

    def self.client_options
      {
        host: Procore.configuration.host,
        user_agent: Procore.configuration.user_agent,
      }
    end
  end
end
