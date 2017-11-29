module Procore
  module Auth
    module Stores
      class Memory
        attr_reader :key, :store
        def initialize(key:)
          @key = key
          @store = {}
        end

        def save(token)
          @store[key] = token
        end

        def fetch
          @store[key]
        end

        def delete
          @store.delete(key)
        end

        def to_s
          "Memory, Key: #{key}"
        end
      end
    end
  end
end
