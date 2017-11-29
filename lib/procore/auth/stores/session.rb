module Procore
  module Auth
    module Stores
      SESSION_KEY = "procore_token".to_sym

      class Session
        attr_reader :session, :key
        def initialize(session:, key: SESSION_KEY)
          @session = session
        end

        def save(token)
          session[key] = token.to_json
        end

        def fetch
          return if session[key].nil?

          token = JSON.parse(session[key])
          Procore::Auth::Token.new(
            access_token: token["access_token"],
            refresh_token: token["refresh_token"],
            expires_at: token["expires_at"],
          )
        end

        def delete
          session[key] = nil
        end

        def to_s
          "Session, Key: #{key}"
        end
      end
    end
  end
end
