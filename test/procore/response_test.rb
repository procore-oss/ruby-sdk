require "test_helper"

class Procore::Response::BodyTest < Minitest::Test
  def test_response_body
    response = Procore::Response.new(
      body: { key: "value" }.to_json,
      code: 200,
      headers: {},
      request: nil,
      request_body: nil,
    )

    assert_equal({ "key" => "value" }, response.body)
  end

  def test_response_body_as_collection
    response_body = [{ "key" => "value" }]

    response = Procore::Response.new(
      body: response_body.to_json,
      code: 200,
      headers: {},
      request: nil,
      request_body: nil,
    )

    assert_equal(response_body, response.body)
  end

  def shared_response_pagination_parsing_test(base_path)
    links = %W(
      <#{base_path}/projects?page=1>; rel="first",
      <#{base_path}/projects?page=173>; rel="last",
      <#{base_path}/projects?page=6>; rel="next",
      '#{base_path}/projects?page=4>; rel="prev"
    ).join(" ")

    response = Procore::Response.new(
      body: [{ key: "value" }].to_json,
      code: 200,
      headers: { link: links },
      request: nil,
      request_body: nil,
    )

    assert_equal(
      {
        first: "projects?page=1",
        last: "projects?page=173",
        next: "projects?page=6",
        prev: "projects?page=4",
      },
      response.pagination,
    )
  end

  def test_rest_response_pagination_parsing
    shared_response_pagination_parsing_test("http://localhost:3000/rest/v1.0")
  end

  def test_vapid_response_pagination_parsing
      shared_response_pagination_parsing_test("http://localhost:3000/vapid")
  end

  def test_login_response_pagination_parsing
      shared_response_pagination_parsing_test("http://localhost:3000/api/v1")
  end

  def shared_response_pagination_parsing_on_first_page(base_path)
    links = %W(
      <#{base_path}/projects?page=173>; rel="last",
      <#{base_path}/projects?page=6>; rel="next"
    ).join(" ")

    response = Procore::Response.new(
      body: [{ key: "value" }].to_json,
      code: 200,
      headers: { link: links },
      request: nil,
      request_body: nil,
    )

    assert_equal(
      {
        last: "projects?page=173",
        next: "projects?page=6",
      },
      response.pagination,
    )
  end

  def test_vapid_response_pagination_parsing_on_first_page
    shared_response_pagination_parsing_on_first_page("http://localhost:3000/vapid")
  end

  def test_rest_response_pagination_parsing_on_first_page
    shared_response_pagination_parsing_on_first_page("http://localhost:3000/rest/v1.0")
  end

  def test_response_pagination_no_links
    response = Procore::Response.new(
      body: [{ key: "value" }].to_json,
      code: 200,
      headers: {
        link: "",
      },
      request: nil,
      request_body: nil,
    )

    assert_equal({}, response.pagination)
  end

  def test_request_body
    request_body = { key: "value" }

    response = Procore::Response.new(
      body: nil,
      code: 200,
      headers: {},
      request: nil,
      request_body: request_body,
    )

    assert_equal(request_body, response.request_body)
  end
end
