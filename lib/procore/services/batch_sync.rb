# frozen_string_literal: true

# Used for large amounts of data syncing to Procore at one time
# This class will batch the records
module Procore
  module Services
    class BatchSync
      BATCH_SIZE = 500.freeze

      def initialize(url:, arguments: {}, updates:, connection:)
        @url = url
        @arguments = arguments
        @updates = updates
        @connection = connection
      end

      attr_accessor :url, :arguments, :updates, :connection

      def execute
        entities = []
        errors = []
        batches.each do |batch|
          sync_arguments = arguments.merge(updates: batch.compact)
          response = connection.patch(url, sync_arguments).body
          entities += response['entities'] if response['entities']&.is_a?(Array)
          errors += response['errors'] if response['errors']&.is_a?(Array)
        end

        { entities: entities, errors: errors }
      end

      private

      def batches
        updates.in_groups_of(BATCH_SIZE)
      end
    end
  end
end
