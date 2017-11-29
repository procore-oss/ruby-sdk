require "test_helper"

class Procore::Auth::ClientCredentialsTest < Minitest::Test
  def test_refresh_token
    stub_request(:post, "https://procore.example.com/oauth/token").
      with(body: {
        "client_id" => "id",
        "client_secret" => "secret",
        "grant_type" => "refresh_token",
        "refresh_token" => "refresh",
      })
      .to_return(
        status: 200,
        body: {
          "access_token":"New Token",
          "token_type":"bearer",
          "expires_in":7200,
          "refresh_token":"New Refresh",
          "created_at":Time.now.to_i
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    credentials = Procore::Auth::AccessTokenCredentials.new(
      client_id: "id",
      client_secret: "secret",
      host: "https://procore.example.com"
    )

    new_token = credentials.refresh(token: "token", refresh: "refresh")

    assert_equal "New Token", new_token.access_token
    assert_equal "New Refresh", new_token.refresh_token
    refute new_token.expired?
  end
end
