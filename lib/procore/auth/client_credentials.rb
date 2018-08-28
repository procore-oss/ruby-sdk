require "oauth2"

module Procore
  module Auth
    class ClientCredentials
      attr_reader :client_id, :client_secret

      def initialize(client_id:, client_secret:)
        unless client_id && client_secret
          raise OAuthError.new("No client_id or client_secret provided.")
        end

        @client_id = client_id
        @client_secret = client_secret
      end

      def refresh(*)
        begin
          new_token = client
            .client_credentials
            .get_token({}, auth_scheme: :request_body)

          Procore::Auth::Token.new(
            access_token: new_token.token,
            refresh_token: new_token.refresh_token,
            expires_at: new_token.expires_at,
          )
        rescue OAuth2::Error => e
          raise OAuthError.new(e.description, response: e.response)
        rescue Faraday::ConnectionFailed => e
          raise APIConnectionError.new("Connection Error: #{e.message}")
        rescue URI::BadURIError
          raise OAuthError.new(
            "Host is not a valid URI. Check your host option to make sure it "   \
            "is a properly formed url",
          )
        end
      end

      private

      def client
        OAuth2::Client.new(
          client_id,
          client_secret,
          site: "#{Procore.configuration.auth_host}/oauth/token",
        )
      end
    end
  end
end
