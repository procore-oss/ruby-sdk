# frozen_string_literal: true

# Used for large amounts of data syncing to Procore at one time
# This class will batch the records
module Procore
  module Services
    class BatchSync
      BATCH_SIZE = 500.freeze

      def initialize(url:, options: {}, updates:, connection:, batch_size: BATCH_SIZE)
        @url = url
        @options = options
        @updates = updates
        @connection = connection
        @batch_size = batch_size
      end

      def execute
        batches.each_with_object( { entities: [], errors: [] } ) do |batch, results|
          sync_arguments = options.merge(updates: batch)
          response = connection.patch(url, sync_arguments).body
          results[:entities] += response['entities'] if response['entities']&.is_a?(Array)
          results[:errors] += response['errors'] if response['errors']&.is_a?(Array)
        end
      end

      private

      attr_reader :url, :options, :updates, :connection, :batch_size

      def batches
        updates.in_groups_of(batch_size, false)
      end
    end
  end
end
