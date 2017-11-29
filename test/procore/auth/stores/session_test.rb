require "test_helper"
require "action_dispatch"

class Procore::Auth::Stores::SessionTest < Minitest::Test
  def setup
    @session = ActionDispatch::Session::CookieStore.new({})
    @store = Procore::Auth::Stores::Session.new(session: {})
    @store.save(
      Procore::Auth::Token.new(
        access_token: "token",
        refresh_token: "refresh",
        expires_at: 55,
      )
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
      )
    )

    assert_equal "new token", @store.fetch.access_token
  end

  def test_store_delete
    @store.delete

    assert_nil @store.fetch
  end
end
