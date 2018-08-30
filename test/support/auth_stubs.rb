module AuthStubs
  def stub_client_credentials_token
    stub_request(:post, "https://login.procore.com/oauth/token")
      .to_return(
        status: 200,
        body: { access_token: "token" }.to_json,
        headers: { "Content-Type" => "application/json" },
      )
  end

  def stub_refresh_token
    stub_request(:post, "https://login.procore.com/oauth/token")
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
  end
end
