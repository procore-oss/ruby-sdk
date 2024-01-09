require "test_helper"

class Procore::ClientTest < Minitest::Test
  include AuthStubs
  include Database

  def setup
    setup_db
  end

  def test_client_creation
    store = Procore::Auth::Stores::Memory.new(key: 1)
    client = Procore::Client.new(
      client_id: "client id",
      client_secret: "client secret",
      store: store,
    )

    assert_equal "https://procore.example.com", client.options[:host]
    assert_equal Procore::Defaults::USER_AGENT, client.options[:user_agent]
  end

  def test_client_option_overrides
    store = Procore::Auth::Stores::Memory.new(key: 1)
    client = Procore::Client.new(
      client_id: "client id",
      client_secret: "client secret",
      store: store,
      options: {
        host: "https://example.com",
        login_host: "https://my-auth-provider.com",
        default_version: "v1.0",
        user_agent: "Procore Test Suite",
      },
    )

    assert_equal "https://example.com", client.options[:host]
    assert_equal "Procore Test Suite", client.options[:user_agent]
    assert_equal "https://my-auth-provider.com", client.options[:login_host]
  end

  def test_client_active_recored_expired_token
    stub_refresh_token
    stub_request(:get, "https://procore.example.com/rest/v1.0/me")

    user = User.create(
      access_token: "token",
      refresh_token: "refresh",
      expires_at: 2.hours.ago,
    )

    store = Procore::Auth::Stores::ActiveRecord.new(object: user)
    client = Procore::Client.new(
      client_id: "client_id",
      client_secret: "client secret",
      store: store,
      options: {
        default_version: "v1.0",
      },
    )

    client.get("me")
    assert_requested stub_refresh_token
  end

  def test_client_no_token
    user = User.create(
      access_token: nil,
      refresh_token: "refresh",
      expires_at: 2.hours.ago,
    )

    store = Procore::Auth::Stores::ActiveRecord.new(object: user)
    client = Procore::Client.new(
      client_id: "client_id",
      client_secret: "client secret",
      store: store,
      options: {
        default_version: "v1.0",
      },
    )

    assert_raises(Procore::MissingTokenError) do
      client.get("me")
    end
  end

  def test_client_token_refresh
    stub_refresh_token

    user = User.create(
      access_token: "token",
      refresh_token: "refresh",
      expires_at: 2.hours.from_now,
    )

    store = Procore::Auth::Stores::ActiveRecord.new(object: user)
    client = Procore::Client.new(
      client_id: "client id",
      client_secret: "client secret",
      store: store,
    )

    client.refresh

    assert_requested stub_refresh_token
  end

  def test_client_token_revoke
    stub_revoke_token

    user = User.create(
      access_token: "token",
      refresh_token: "refresh",
      expires_at: 2.hours.from_now,
    )

    store = Procore::Auth::Stores::ActiveRecord.new(object: user)
    client = Procore::Client.new(
      client_id: "client id",
      client_secret: "client secret",
      store: store,
    )

    client.revoke

    assert_requested stub_revoke_token
  end
end
