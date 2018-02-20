require "test_helper"

class Procore::RequestableTest < Minitest::Test
  class Request
    include Procore::Requestable

    attr_reader :access_token
    def initialize(token:)
      @access_token = token
    end

    def base_api_path
      "http://test.com"
    end
  end

  def test_get
    stub_request(:get, "http://test.com/home?per_page=5")
      .with(headers: {
              "Accepts" => "application/json",
              "Authorization" => "Bearer token",
              "Content-Type" => "application/json",
            })
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").get("home", per_page: 5)
  end

  def test_post
    stub_request(:post, "http://test.com/home")
      .with(
        body: { name: "Name" },
        headers: {
          "Accepts" => "application/json",
          "Authorization" => "Bearer token",
          "Content-Type" => "application/json",
        },
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").post("home", name: "Name")
  end

  def test_put
    stub_request(:put, "http://test.com/home")
      .with(
        body: { name: "Replaced Name" },
        headers: {
          "Accepts" => "application/json",
          "Authorization" => "Bearer token",
          "Content-Type" => "application/json",
        },
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").put("home", name: "Replaced Name")
  end

  def test_patch
    stub_request(:patch, "http://test.com/home")
      .with(
        body: { name: "New Name" },
        headers: {
          "Accepts" => "application/json",
          "Authorization" => "Bearer token",
          "Content-Type" => "application/json",
        },
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").patch("home", name: "New Name")
  end

  def test_delete
    stub_request(:delete, "http://test.com/home")
      .with(headers: {
              "Accepts" => "application/json",
              "Authorization" => "Bearer token",
              "Content-Type" => "application/json",
            })
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").delete("home")
  end

  def test_post_with_idempotency_token
    stub_request(:post, "http://test.com/home")
      .with(headers: {
              "Accepts" => "application/json",
              "Authorization" => "Bearer token",
              "Content-Type" => "application/json",
              "Idempotency-Token" => "token",
            })
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").post("home", {}, idempotency_token: "token")
  end

  def test_post_with_multipart_body
    stub_request(:post, "http://test.com/home")
      .with(headers: {
              "Accepts" => "application/json",
              "Authorization" => "Bearer token",
              "Content-Type" => %r[multipart/form-data]
            })
      .to_return(status: 200, body: "", headers: {})
    pixel = File.new('test/support/pixel.png', 'r')

    Request.new(token: "token").post("home", file: pixel)
  end

  def test_unauthorized_error
    stub_request(:get, "http://test.com")
      .to_return(status: 401, body: "", headers: {})

    assert_raises Procore::AuthorizationError do
      Request.new(token: "token").get("")
    end
  end

  def test_not_found_error
    stub_request(:get, "http://test.com")
      .to_return(status: 404, body: "", headers: {})

    assert_raises Procore::NotFoundError do
      Request.new(token: "token").get("")
    end
  end

  def test_server_error
    stub_request(:get, "http://test.com")
      .to_return(status: 500, body: "", headers: {})

    assert_raises Procore::ServerError do
      Request.new(token: "token").get("")
    end
  end

  def test_error_body
    stub_request(:get, "http://test.com")
      .to_return(
        status: 401,
        body: { errors: "Unauthorized" }.to_json,
        headers: {},
      )

    begin
      Request.new(token: "token").get("")
    rescue Procore::AuthorizationError => e
      assert_equal({ "errors" => "Unauthorized" }, e.response.body)
    end
  end
end
