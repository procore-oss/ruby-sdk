require "test_helper"

class Procore::Auth::TokenTest < Minitest::Test
  def test_token_creation
    token = Procore::Auth::Token.new(
      access_token: "token",
      refresh_token: "refresh",
      expires_at: 1.hour.from_now,
    )

    assert_equal "token", token.access_token
    assert_equal "refresh", token.refresh_token
    assert_in_delta 1.hour.from_now, token.expires_at, 0.01
  end

  def test_expiration_for_valid_token
    token = Procore::Auth::Token.new(
      access_token: "token",
      refresh_token: "refresh",
      expires_at: 1.hour.from_now,
    )

    refute token.expired?
  end

  def test_expiration_for_expired_token
    token = Procore::Auth::Token.new(
      access_token: "token",
      refresh_token: "refresh",
      expires_at: 1.hour.ago,
    )

    assert token.expired?
  end

  def test_expiration_for_nil_expiration
    token = Procore::Auth::Token.new(
      access_token: "token",
      refresh_token: "refresh",
      expires_at: nil,
    )

    assert token.expired?
  end

  def test_valid_token
    token = Procore::Auth::Token.new(
      access_token: "token",
      refresh_token: "refresh",
      expires_at: 1.hour.from_now,
    )

    refute token.invalid?
  end

  def test_invalid_token
    token = Procore::Auth::Token.new(
      access_token: nil,
      refresh_token: "refresh",
      expires_at: 1.hour.ago,
    )

    assert token.invalid?
  end
end
