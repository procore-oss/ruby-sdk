module Procore
  module Auth
    module Stores
      class ActiveRecord
        attr_reader :object

        def initialize(object:)
          @object = object
        end

        def save(token)
          object.update(
            access_token: token.access_token,
            refresh_token: token.refresh_token,
            expires_at: token.expires_at,
          )
        end

        def fetch
          Procore::Auth::Token.new(
            access_token: object.access_token,
            refresh_token: object.refresh_token,
            expires_at: object.expires_at,
          )
        end

        def delete
          object.update(
            access_token: nil,
            expires_at: nil,
            refresh_token: nil,
          )
        end

        def to_s
          "Active Record, Object: #{object.class} #{object.id}"
        end
      end
    end
  end
end
