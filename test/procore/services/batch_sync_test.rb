# frozen_string_literal: true

require 'test_helper'

class Procore::Services::BatchSyncTest < Minitest::Test
  def test_execute
    updates = (0..1000).to_a.map { |count| { id: count, origin_id: "origin_id_#{count}" } }
    oauth_connection = Minitest::Mock.new

    url = '/projects/sync'

    batch1 = updates[0..499]
    batch1_sync_result = Minitest::Mock.new
    batch1_sync_result.expect :body, { 'entities' => [{ 'id' => 1, 'origin_id' => 'batch1' }] }
    oauth_connection.expect :patch, batch1_sync_result, [url, { view: :compact, updates: batch1 }]

    batch2 = updates[500..999]
    batch2_sync_result = Minitest::Mock.new
    batch2_sync_result.expect :body, { 'entities' => [{ 'id' => 2, 'origin_id' => 'batch2' }] }
    oauth_connection.expect :patch, batch2_sync_result, [url, { view: :compact, updates: batch2 }]

    batch3 = [updates[1000]]
    batch3_sync_result = Minitest::Mock.new
    batch3_sync_result.expect :body, { 'errors' => [{ 'id' => 3, 'origin_id' => 'batch3' }] }
    oauth_connection.expect :patch, batch3_sync_result, [url, { view: :compact, updates: batch3 }]

    batch_sync_service = Procore::Services::BatchSync.new(url: url, arguments: { view: :compact }, updates: updates, connection: oauth_connection)
    sync_result = batch_sync_service.execute

    expected_sync_result = {
      entities: [
        { 'id' => 1, 'origin_id' => 'batch1' },
        { 'id' => 2, 'origin_id' => 'batch2' }
      ],
      errors: [
        { 'id' => 3, 'origin_id' => 'batch3' }
      ]
    }
    assert_equal(sync_result, expected_sync_result)
  end

  def test_execute_with_custom_batch_size
    updates = (0..5).to_a.map { |count| { id: count, origin_id: "origin_id_#{count}" } }
    oauth_connection = Minitest::Mock.new

    url = '/projects/sync'

    batch1 = updates[0..4]
    batch1_sync_result = Minitest::Mock.new
    batch1_sync_result.expect :body, { 'entities' => [{ 'id' => 1, 'origin_id' => 'batch1' }] }
    oauth_connection.expect :patch, batch1_sync_result, [url, { updates: batch1 }]

    batch2 = [updates[5]]
    batch2_sync_result = Minitest::Mock.new
    batch2_sync_result.expect :body, { 'errors' => [{ 'id' => 2, 'origin_id' => 'batch2' }] }
    oauth_connection.expect :patch, batch2_sync_result, [url, { updates: batch2 }]

    batch_sync_service = Procore::Services::BatchSync.new(url: url, updates: updates, connection: oauth_connection, batch_size: 5)
    sync_result = batch_sync_service.execute

    expected_sync_result = {
      entities: [
        { 'id' => 1, 'origin_id' => 'batch1' }
      ],
      errors: [
        { 'id' => 2, 'origin_id' => 'batch2' }
      ]
    }
    assert_equal(sync_result, expected_sync_result)
  end
end
