require "test_helper"
require "fakefs/safe"

# FakeFS Stub for YAML Store. Since FakeFS doesn't implement File#flock.
module FakeFS
  class File
    def flock(*)
    end
  end
end

class Procore::Auth::Stores::FileTest < Minitest::Test
  def setup
    FakeFS.activate!
    @store = Procore::Auth::Stores::File.new(key: 1, path: "./tokens.yml")
    @store.save(
      Procore::Auth::Token.new(
        access_token: "token",
        refresh_token: "refresh",
        expires_at: 55,
      ),
    )
  end

  def teardown
    FakeFS.deactivate!
  end

  def test_store_token
    assert_equal "token", @store.fetch.access_token
  end

  def test_overwrite_existing
    @store.save(
      Procore::Auth::Token.new(
        access_token: "new token",
        refresh_token: "new refresh",
        expires_at: 55,
      ),
    )

    assert_equal "new token", @store.fetch.access_token
  end

  def test_store_delete
    @store.delete

    assert_nil @store.fetch
  end
end
