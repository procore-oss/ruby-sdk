# frozen_string_literal: true

# Used for large amounts of data syncing to Procore at one time
# This class will batch the records
module Procore
  module Services
    class BatchSync
      BATCH_SIZE = 500.freeze

      def initialize(url:, arguments: {}, updates:, connection:, batch_size: BATCH_SIZE)
        @url = url
        @arguments = arguments
        @updates = updates
        @connection = connection
        @batch_size = batch_size
      end

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

      attr_reader :url, :arguments, :updates, :connection, :batch_size

      def batches
        updates.in_groups_of(batch_size)
      end
    end
  end
end
