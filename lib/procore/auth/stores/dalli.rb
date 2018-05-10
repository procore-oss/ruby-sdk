module Procore
  module Auth
    module Stores
      class Dalli
        attr_reader :key, :dalli
        def initialize(key:, dalli:)
          @key = key
          @dalli = dalli
        end

        def save(token)
          dalli.set(dalli_key, token.to_json)
        end

        def fetch
          return unless dalli.get(dalli_key)

          token = JSON.parse(dalli.get(dalli_key))
          Procore::Auth::Token.new(
            access_token: token["access_token"],
            refresh_token: token["refresh_token"],
            expires_at: token["expires_at"],
          )
        end

        def delete
          dalli.delete(dalli_key)
        end

        private

        def dalli_key
          "procore-dalli-#{key}"
        end
      end
    end
  end
end
