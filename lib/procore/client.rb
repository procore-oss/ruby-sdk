require "procore/requestable"

module Procore
  # Main class end users interact with. An instance of a client can call out
  # the Procore API using methods matching standard HTTP verbs #get, #post,
  # #put, #patch, #delete.
  #
  # @example Creating a new client:
  #   store = Procore::Auth::Stores::Session.new(session: session)
  #   client = Procore::Client.new(
  #     client_id: Rails.application.secrets.procore_client_id,
  #     client_secret: Rails.application.secrets.procore_secret_id,
  #     store: store
  #   )
  #
  #   client.get("me").body #=> { id: 5, email: "person@example.com" }
  class Client
    include Procore::Requestable

    attr_reader :options, :store

    # @param client_id [String] Client ID issued from Procore
    # @param client_secret [String] Client Secret issued from Procore
    # @param store [Auth::Store] A store to use for saving, updating and
    #   refreshing tokens
    # @param options [Hash] options to configure the client with
    # @option options [String] :host Endpoint to use for the API. Defaults to
    #   Configuration.host
    # @option options [String] :user_agent User Agent string to send along with
    #   the request. Defaults to Configuration.user_agent
    def initialize(client_id:, client_secret:, store:, options: {})
      @options = Procore::Defaults::client_options.merge(options)

      host = @options[:login_host] || @options[:host]
      @credentials = Procore::Auth::AccessTokenCredentials.new(
        client_id: client_id,
        client_secret: client_secret,
        host: host,
      )
      @store = store
    end

    # @raise [OAuthError] if a token cannot be refreshed.
    def refresh
      token = fetch_token

      begin
        new_token = @credentials.refresh(
          token: token.access_token,
          refresh: token.refresh_token,
        )

        Util.log_info("Token Refresh Successful", store: store)
        store.save(new_token)
      rescue RuntimeError
        Util.log_error("Token Refresh Failed", store: store)
        raise Procore::OAuthError.new(
          "Unable to refresh the access token. Perhaps the Procore API is "  \
          "down or your access token store is misconfigured. Either "    \
          "way, you should clear the store and prompt the user to sign in "  \
          "again.",
        )
      end
    end

    # @raise [OAuthError] if a token cannot be revoked.
    def revoke
      token = fetch_token

      begin
        @credentials.revoke(token: token)
        Util.log_info("Token Revocation Successful", store: store)
      rescue RuntimeError
        Util.log_error("Token Revocation Failed", store: store)
        raise Procore::OAuthError.new(
          "Unable to revoke the access token. Perhaps the Procore API is "  \
          "down or your access token store is misconfigured. Either "    \
          "way, you should clear the store and prompt the user to sign in "  \
          "again.",
        )
      end
    end

    private

    def base_api_path
      "#{options[:host]}"
    end

    # @raise [OAuthError] if the store does not have a token stored.
    def fetch_token
      token = store.fetch
      if token.nil? || token.invalid?
        raise Procore::MissingTokenError.new(
          "Unable to retreive an access token from the store. Double check "   \
          "your store configuration and make sure to correctly store a token " \
          "before attempting to make API requests",
        )
      end
      token
    end

    def access_token
      token = fetch_token
      if token.expired?
        Util.log_info("Token Expired", store: store)
        refresh
        token = fetch_token
      end
      token.access_token
    end
  end
end
