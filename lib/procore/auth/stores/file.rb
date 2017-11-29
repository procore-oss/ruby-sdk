require "yaml/store"

module Procore
  module Auth
    module Stores
      class File
        attr_reader :key, :path
        def initialize(key:, path:)
          @key = key
          @path = path
          @store = YAML::Store.new(path)
        end

        def save(token)
          @store.transaction { @store[key] = token }
        end

        def fetch
          @store.transaction { @store[key] }
        end

        def delete
          @store.transaction { @store.delete(key) }
        end

        def to_s
          "File, Key: #{key}, Path: #{path}"
        end
      end
    end
  end
end
