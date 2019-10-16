require "test_helper"

class Procore::RequestableTest < Minitest::Test
  class Request
    include Procore::Requestable

    attr_reader :access_token, :api_version
    def initialize(token:, api_version: 'vapid')
      @access_token = token
      @api_version = api_version
    end

    def base_api_path
      "http://test.com/#{@api_version}"
    end
  end

  def test_get
    request = stub_request(:get, "http://test.com/vapid/home")
      .with(
        query: { per_page: 5 },
        headers: {
          "Accepts" => "application/json",
          "Authorization" => "Bearer token",
          "Content-Type" => "application/json",
        },
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").get("home", query: { per_page: 5 })

    assert_requested request
  end

  def test_rest_get
    request = stub_request(:get, "http://test.com/rest/home")
      .with(
        query: { per_page: 5 },
        headers: {
          "Accepts" => "application/json",
          "Authorization" => "Bearer token",
          "Content-Type" => "application/json",
        },
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token", api_version: 'rest').get("home", query: { per_page: 5 })

    assert_requested request
  end

  def test_post
    request = stub_request(:post, "http://test.com/vapid/home")
      .with(
        body: { name: "Name" },
        headers: {
          "Accepts" => "application/json",
          "Authorization" => "Bearer token",
          "Content-Type" => "application/json",
        },
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").post("home", body: { name: "Name" })

    assert_requested request
  end

  def test_rest_post
    request = stub_request(:post, "http://test.com/rest/home")
      .with(
        body: { name: "Name" },
        headers: {
          "Accepts" => "application/json",
          "Authorization" => "Bearer token",
          "Content-Type" => "application/json",
        },
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token", api_version: 'rest').post("home", body: { name: "Name" })

    assert_requested request
  end

  def test_put
    request = stub_request(:put, "http://test.com/vapid/home")
      .with(
        body: { name: "Replaced Name" },
        headers: {
          "Accepts" => "application/json",
          "Authorization" => "Bearer token",
          "Content-Type" => "application/json",
        },
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").put("home", body: { name: "Replaced Name" })

    assert_requested request
  end

  def test_rest_put
    request = stub_request(:put, "http://test.com/rest/home")
      .with(
        body: { name: "Replaced Name" },
        headers: {
          "Accepts" => "application/json",
          "Authorization" => "Bearer token",
          "Content-Type" => "application/json",
        },
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token", api_version: 'rest').put("home", body: { name: "Replaced Name" })

    assert_requested request
  end

  def test_patch
    request = stub_request(:patch, "http://test.com/vapid/home")
      .with(
        body: { name: "New Name" },
        headers: {
          "Accepts" => "application/json",
          "Authorization" => "Bearer token",
          "Content-Type" => "application/json",
        },
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").patch("home", body: { name: "New Name" })

    assert_requested request
  end

  def test_delete
    request = stub_request(:delete, "http://test.com/vapid/home")
      .with(headers: {
              "Accepts" => "application/json",
              "Authorization" => "Bearer token",
              "Content-Type" => "application/json",
            })
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").delete("home")

    assert_requested request
  end

  def test_sync
    update1 = [{ id: 4, name: "Updated Project 4" }]
    request1 = stub_request(:patch, "http://test.com/vapid/projects/sync")
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
    request2 = stub_request(:patch, "http://test.com/vapid/projects/sync")
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
    request = stub_request(:post, "http://test.com/vapid/home")
      .with(
        headers: {
          "Accepts" => "application/json",
          "Authorization" => "Bearer token",
          "Content-Type" => "application/json",
          "Idempotency-Token" => "token",
        },
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
    request = stub_request(:get, "http://test.com/vapid/home")
      .with(
        headers: {
          "Accepts" => "application/json",
          "Authorization" => "Bearer token",
          "Content-Type" => "application/json",
          "procore-company-id" => "1",
        },
      )
      .to_return(status: 200, body: "", headers: {})

    Request.new(token: "token").get(
      "home",
      options: { company_id: 1 },
    )

    assert_requested request
  end

  def test_post_with_company_id
    request = stub_request(:post, "http://test.com/vapid/home")
      .with(
        body: { name: "Name" },
        headers: {
          "Accepts" => "application/json",
          "Authorization" => "Bearer token",
          "Content-Type" => "application/json",
          "procore-company-id" => "1",
        },
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
    request = stub_request(:post, "http://test.com/vapid/home")
      .with(
        headers: {
          "Accepts" => "application/json",
          "Authorization" => "Bearer token",
          "Content-Type" => %r[multipart/form-data],
        },
      )
      .to_return(status: 200, body: "", headers: {})

    pixel = File.new("test/support/pixel.png", "r")

    Request.new(token: "token").post("home", body: { file: pixel })

    assert_requested request
  end

  def test_unauthorized_error
    stub_request(:get, "http://test.com/vapid/")
      .to_return(status: 401, body: "", headers: {})

    assert_raises Procore::AuthorizationError do
      Request.new(token: "token").get("")
    end
  end

  def test_forbidden_error
    stub_request(:get, "http://test.com/vapid/")
      .to_return(status: 403, body: "", headers: {})

    assert_raises Procore::ForbiddenError do
      Request.new(token: "token").get("")
    end
  end

  def test_not_found_error
    stub_request(:get, "http://test.com/vapid/")
      .to_return(status: 404, body: "", headers: {})

    assert_raises Procore::NotFoundError do
      Request.new(token: "token").get("")
    end
  end

  def test_server_error
    stub_request(:get, "http://test.com/vapid/")
      .to_return(status: 500, body: "", headers: {})

    assert_raises Procore::ServerError do
      Request.new(token: "token").get("")
    end
  end

  def test_error_body
    stub_request(:get, "http://test.com/vapid/")
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
