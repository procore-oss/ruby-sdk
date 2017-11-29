require "test_helper"

class Procore::Auth::ClientCredentialsTest < Minitest::Test
  def test_get_token
    stub_request(:post, "https://procore.example.com/oauth/token")
      .with(body: {
        "client_id" => "id",
        "client_secret" => "secret",
        "grant_type" => "client_credentials",
      })
      .to_return(
        status: 200,
        body: { access_token: "token" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    token = Procore::Auth::ClientCredentials.new(
      client_id: "id",
      client_secret: "secret",
      host: "https://procore.example.com"
    ).refresh

    assert_equal "token", token.access_token
  end
end
