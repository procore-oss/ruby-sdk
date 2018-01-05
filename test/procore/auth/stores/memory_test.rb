require "test_helper"

class Procore::Auth::Stores::MemoryTest < Minitest::Test
  def setup
    @store = Procore::Auth::Stores::Memory.new(key: 1)
    @store.save(
      Procore::Auth::Token.new(
        access_token: "token",
        refresh_token: "refresh",
        expires_at: 55,
      ),
    )
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

  def test_delete
    @store.delete

    assert_nil @store.fetch
  end
end
