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
          return if redis.get(redis_key).empty?

          token = JSON.parse(redis.get(redis_key))
          Procore::Auth::Token.new(
            access_token: token["access_token"],
            refresh_token: token["refresh_token"],
            expires_at: token["expires_at"],
          )
        end

        def delete
          redis.set(redis_key, nil)
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
