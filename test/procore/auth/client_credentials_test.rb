require "test_helper"

class Procore::Auth::ClientCredentialsTest < Minitest::Test
  def test_get_token
    stub_request(:post, "https://login.procore.com/oauth/token")
      .with(body: {
              "client_id" => "id",
              "client_secret" => "secret",
              "grant_type" => "client_credentials",
            })
      .to_return(
        status: 200,
        body: { access_token: "token" }.to_json,
        headers: { "Content-Type" => "application/json" },
      )

    token = Procore::Auth::ClientCredentials.new(
      client_id: "id",
      client_secret: "secret",
    ).refresh

    assert_equal "token", token.access_token
  end

  def test_oauth_client_error_with_html
    stub_request(:post, "https://login.procore.com/oauth/token")
      .with(body: {
              "client_id" => "id",
              "client_secret" => "secret",
              "grant_type" => "client_credentials",
            })
      .to_return(
        status: 500,
        body: "<html><body><h1>This is very bad</h1></body></html>",
        headers: { "Content-Type" => "text/html" },
      )

    token = Procore::Auth::ClientCredentials.new(
      client_id: "id",
      client_secret: "secret",
    )

    error = assert_raises Procore::OAuthError do
      token.refresh
    end

    assert_equal error.response.code, 500
    assert_equal error.response.body, "<html><body><h1>This is very bad</h1></body></html>"
    assert_equal error.response.headers, "content-type" => "text/html"
    assert_nil error.response.request.path
    assert_equal error.response.request.options, {}
  end

  def test_oauth_client_error_with_json
    stub_request(:post, "https://login.procore.com/oauth/token")
      .with(body: {
              "client_id" => "id",
              "client_secret" => "secret",
              "grant_type" => "client_credentials",
            })
      .to_return(
        status: 500,
        body: { error: "Some bad error" }.to_json,
        headers: { "Content-Type" => "application/json" },
      )

    token = Procore::Auth::ClientCredentials.new(
      client_id: "id",
      client_secret: "secret",
    )

    error = assert_raises Procore::OAuthError do
      token.refresh
    end

    assert_equal error.response.code, 500
    assert_equal error.response.body, "error" => "Some bad error"
    assert_equal error.response.headers, "content-type" => "application/json"
    assert_nil error.response.request.path
    assert_equal error.response.request.options, {}
  end

  def test_connection_failed_error
    stub_request(:post, "https://login.procore.com/oauth/token")
      .with(
        body: {
          "client_id" => "id",
          "client_secret" => "secret",
          "grant_type" => "client_credentials",
        },
      ).to_timeout

    token = Procore::Auth::ClientCredentials.new(
      client_id: "id",
      client_secret: "secret",
    )

    assert_raises Procore::APIConnectionError do
      token.refresh
    end
  end

  def test_procore_oauth_error
    stub_request(:post, "https://login.procore.com/oauth/token")
      .with(
        body: {
          "client_id" => "id",
          "client_secret" => "secret",
          "grant_type" => "client_credentials",
        },
      )

    token = Procore::Auth::ClientCredentials.new(
      client_id: "id",
      client_secret: "secret",
    )

    assert_raises Procore::OAuthError do
      token.refresh
    end
  end
end
