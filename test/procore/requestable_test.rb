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

    def options
      {
        default_version: "v1.0",
      }
    end
  end

  def headers
    {
      "Accepts" => "application/json",
      "Authorization" => "Bearer token",
      "Content-Type" => "application/json",
      "Procore-Sdk-Version" => Procore::VERSION,
      "Procore-Sdk-Language" => "ruby",
    }
  end

  def test_get
    request = stub_request(:get, "http://test.com/rest/v1.0/home")
      .with(
        query: { per_page: 5 },
        headers: headers
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").get("home", query: { per_page: 5 })

    assert_requested request
  end

  def test_rest_get
    request = stub_request(:get, "http://test.com/rest/v1.1/home")
      .with(
        query: { per_page: 5 },
        headers: headers
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").get("home", version: "v1.1", query: { per_page: 5 })

    assert_requested request
  end

  def test_vapid_get
    request = stub_request(:get, "http://test.com/vapid/home")
      .with(
        query: { per_page: 5 },
        headers: headers
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").get("home", version: "vapid", query: { per_page: 5 })

    assert_requested request
  end

  def test_post
    request = stub_request(:post, "http://test.com/rest/v1.0/home")
      .with(
        body: { name: "Name" },
        headers: headers
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").post("home", body: { name: "Name" })

    assert_requested request
  end

  def test_rest_post
    request = stub_request(:post, "http://test.com/rest/v1.1/home")
      .with(
        body: { name: "Name" },
        headers: headers
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").post("home", version: "v1.1", body: { name: "Name" })

    assert_requested request
  end

  def test_vapid_post
    request = stub_request(:post, "http://test.com/vapid/home")
      .with(
        body: { name: "Name" },
        headers: headers
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").post("home", version: "vapid", body: { name: "Name" })

    assert_requested request
  end

  def test_put
    request = stub_request(:put, "http://test.com/rest/v1.0/home")
      .with(
        body: { name: "Replaced Name" },
        headers: headers
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").put("home", body: { name: "Replaced Name" })

    assert_requested request
  end

  def test_rest_put
    request = stub_request(:put, "http://test.com/rest/v1.1/home")
      .with(
        body: { name: "Replaced Name" },
        headers: headers
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").put("home", version: "v1.1", body: { name: "Replaced Name" })

    assert_requested request
  end


  def test_vapid_put
    request = stub_request(:put, "http://test.com/vapid/home")
      .with(
        body: { name: "Replaced Name" },
        headers: headers
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").put("home", version: "vapid", body: { name: "Replaced Name" })

    assert_requested request
  end

  def test_patch
    request = stub_request(:patch, "http://test.com/rest/v1.0/home")
      .with(
        body: { name: "New Name" },
        headers: headers
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").patch("home", body: { name: "New Name" })

    assert_requested request
  end

  def test_delete
    request = stub_request(:delete, "http://test.com/rest/v1.0/home")
      .with(headers: headers)
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").delete("home")

    assert_requested request
  end

  def test_sync
    update1 = [{ id: 4, name: "Updated Project 4" }]
    request1 = stub_request(:patch, "http://test.com/rest/v1.0/projects/sync")
      .with(body: { company_id: 13, updates: update1 })
      .to_return(
        status: 200,
        body: {
          entities: [{ id: 4, name: "Updated Project 4" }],
          errors: [],
        }.to_json,
        headers: {},
      )

    update2 = [{ id: 0, name: "Updated Project 0" }]
    request2 = stub_request(:patch, "http://test.com/rest/v1.0/projects/sync")
      .with(body: { company_id: 13, updates: update2 }).to_return(
        status: 200,
        body: {
          entities: [],
          errors: [{
            id: 0,
            name: "No project has this id value",
            errors: { id: ["Entity with this ID not found"] },
          }],
        }.to_json,
        headers: {},
      )

    response = Request.new(token: "token").sync(
      "projects/sync",
      body: { company_id: 13, updates: update1 + update2 },
      options: { batch_size: 1 },
    )

    assert_requested request1
    assert_requested request2

    expected_body = {
      entities: [{ id: 4, name: "Updated Project 4" }],
      errors: [{
        id: 0,
        name: "No project has this id value",
        errors: { id: ["Entity with this ID not found"] },
      }],
    }
    assert response.body, expected_body
  end

  def test_post_with_idempotency_token
    request = stub_request(:post, "http://test.com/rest/v1.0/home")
      .with(
        headers: headers.merge("Idempotency-Token" => "token"),
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").post(
      "home",
      body: {},
      options: { idempotency_token: "token" },
    )

    assert_requested request
  end

  def test_get_with_company_id
    request = stub_request(:get, "http://test.com/rest/v1.0/home")
      .with(
        headers: headers.merge("procore-company-id" => "1")
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").get(
      "home",
      options: { company_id: 1 },
    )

    assert_requested request
  end

  def test_post_with_company_id
    request = stub_request(:post, "http://test.com/rest/v1.0/home")
      .with(
        body: { name: "Name" },
        headers: headers.merge("procore-company-id" => "1"),
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").post(
      "home",
      body: { name: "Name" },
      options: { company_id: 1 },
    )

    assert_requested request
  end

  def test_post_with_multipart_body
    request = stub_request(:post, "http://test.com/rest/v1.0/home")
      .with(
        headers: headers.merge("Content-Type" => %r[multipart/form-data]),
      )
      .to_return(status: 200, body: "", headers: {})

    pixel = File.new("test/support/pixel.png", "r")

    Request.new(token: "token").post("home", body: { file: pixel })

    assert_requested request
  end

  def test_unauthorized_error
    stub_request(:get, "http://test.com/rest/v1.0/")
      .to_return(status: 401, body: "", headers: {})

    assert_raises Procore::AuthorizationError do
      Request.new(token: "token").get("")
    end
  end

  def test_forbidden_error
    stub_request(:get, "http://test.com/rest/v1.0/")
      .to_return(status: 403, body: "", headers: {})

    assert_raises Procore::ForbiddenError do
      Request.new(token: "token").get("")
    end
  end

  def test_not_found_error
    stub_request(:get, "http://test.com/rest/v1.0/")
      .to_return(status: 404, body: "", headers: {})

    assert_raises Procore::NotFoundError do
      Request.new(token: "token").get("")
    end
  end

  def test_server_error
    stub_request(:get, "http://test.com/rest/v1.0/")
      .to_return(status: 500, body: "", headers: {})

    assert_raises Procore::ServerError do
      Request.new(token: "token").get("")
    end
  end

  def test_error_body
    stub_request(:get, "http://test.com/rest/v1.0/")
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
