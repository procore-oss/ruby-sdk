require "test_helper"

class Procore::Auth::Stores::ActiveRecordTest < Minitest::Test
  include Database

  def setup
    setup_db

    @user = User.create(
      access_token: "token",
      refresh_token: "refresh",
      expires_at: (Time.now.to_i - 2.hours),
    )

    @store = Procore::Auth::Stores::ActiveRecord.new(object: @user)
  end

  def test_store_and_fetch_token
    @store.save(
      Procore::Auth::Token.new(
        access_token: "new token",
        refresh_token: "new refresh",
        expires_at: 55,
      )
    )

    assert_equal "new token", @user.access_token
    assert_equal "new refresh", @user.refresh_token
    assert_equal 55, @user.expires_at

    assert_equal "new token", @store.fetch.access_token
    assert_equal "new refresh", @store.fetch.refresh_token
    assert_equal 55, @store.fetch.expires_at
  end

  def test_store_delete
    @store.delete

    assert_nil @user.access_token
    assert_nil @user.refresh_token
    assert_nil @user.expires_at
  end
end
