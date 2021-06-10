module Procore
  module Auth
    module Stores
      class Redis
        attr_reader :key, :redis
        def initialize(key:, redis:)
          @key = key
          @redis = redis
        end

        def save(token)
          redis.set(redis_key, token.to_json)
        end

        def fetch
          return unless redis.exists?(redis_key)

          token = JSON.parse(redis.get(redis_key))
          Procore::Auth::Token.new(
            access_token: token["access_token"],
            refresh_token: token["refresh_token"],
            expires_at: token["expires_at"],
          )
        end

        def delete
          redis.del(redis_key)
        end

        def to_s
          "Redis, Key: #{redis_key}"
        end

        private

        def redis_key
          "procore-redis-#{key}"
        end
      end
    end
  end
end
