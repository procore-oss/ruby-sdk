require "test_helper"

class Procore::Auth::ClientCredentialsTest < Minitest::Test
  def test_refresh_token
    stub_request(:post, "https://login.procore.com/oauth/token")
      .with(body: {
              "client_id" => "id",
              "client_secret" => "secret",
              "grant_type" => "refresh_token",
              "refresh_token" => "refresh",
            })
      .to_return(
        status: 200,
        body: {
          "access_token": "New Token",
          "token_type": "bearer",
          "expires_in": 7200,
          "refresh_token": "New Refresh",
          "created_at": Time.now.to_i,
        }.to_json,
        headers: { "Content-Type" => "application/json" },
      )

    credentials = Procore::Auth::AccessTokenCredentials.new(
      client_id: "id",
      client_secret: "secret",
    )

    new_token = credentials.refresh(token: "token", refresh: "refresh")

    assert_equal "New Token", new_token.access_token
    assert_equal "New Refresh", new_token.refresh_token
    refute new_token.expired?
  end

  def test_oauth_client_error_with_html
    stub_request(:post, "https://login.procore.com/oauth/token")
      .with(body: {
              "client_id" => "id",
              "client_secret" => "secret",
              "grant_type" => "refresh_token",
              "refresh_token" => "refresh",
            })
      .to_return(
        status: 500,
        body: "<html><body><h1>This is very bad</h1></body></html>",
        headers: { "Content-Type" => "text/html" },
      )

    credentials = Procore::Auth::AccessTokenCredentials.new(
      client_id: "id",
      client_secret: "secret",
    )

    error = assert_raises Procore::OAuthError do
      credentials.refresh(token: "token", refresh: "refresh")
    end

    assert_equal error.response.code, 500
    assert_equal error.response.body, "<html><body><h1>This is very bad</h1></body></html>"
    assert_equal error.response.headers, "content-type" => "text/html"
    assert_nil error.response.request.path
    assert_equal error.response.request.options, {}
  end

  def test_oauth_client_error_with_json
    stub_request(:post, "https://procore.example.com/oauth/token")
      .with(body: {
              "client_id" => "id",
              "client_secret" => "secret",
              "grant_type" => "refresh_token",
              "refresh_token" => "refresh",
            })
      .to_return(
        status: 500,
        body: { error: "Some bad error" }.to_json,
        headers: { "Content-Type" => "application/json" },
      )

    credentials = Procore::Auth::AccessTokenCredentials.new(
      client_id: "id",
      client_secret: "secret",
    )

    error = assert_raises Procore::OAuthError do
      credentials.refresh(token: "token", refresh: "refresh")
    end

    assert_equal error.response.code, 500
    assert_equal error.response.body, "error" => "Some bad error"
    assert_equal error.response.headers, "content-type" => "application/json"
    assert_nil error.response.request.path
    assert_equal error.response.request.options, {}
  end

  def test_connection_failed_error
    stub_request(:post, "https://login.procore.com/oauth/token")
      .with(body: {
              "client_id" => "id",
              "client_secret" => "secret",
              "grant_type" => "refresh_token",
              "refresh_token" => "refresh",
            }).to_timeout

    credentials = Procore::Auth::AccessTokenCredentials.new(
      client_id: "id",
      client_secret: "secret",
    )

    assert_raises Procore::APIConnectionError do
      credentials.refresh(token: "token", refresh: "refresh")
    end
  end
end
