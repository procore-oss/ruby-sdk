require "test_helper"

class Procore::Response::BodyTest < Minitest::Test
  def test_response_body
    response = Procore::Response.new(
      body: { key: "value" }.to_json,
      code: 200,
      headers: {},
      request: nil,
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
    )

    assert_equal(response_body, response.body)
  end

  def test_response_pagination_parsing
    links = '<http://localhost:3000/vapid/projects?page=1>; rel="first", '\
      '<http://localhost:3000/vapid/projects?page=173>; rel="last", '\
      '<http://localhost:3000/vapid/projects?page=6>; rel="next", '\
      '<http://localhost:3000/vapid/projects?page=4>; rel="prev"'

    response = Procore::Response.new(
      body: [{ key: "value" }].to_json,
      code: 200,
      headers: { "link" => links },
      request: nil,
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

  def test_response_pagination_parsing_on_first_page
    links = '<http://localhost:3000/vapid/projects?page=173>; rel="last", '\
      '<http://localhost:3000/vapid/projects?page=6>; rel="next"'

    response = Procore::Response.new(
      body: [{ key: "value" }].to_json,
      code: 200,
      headers: { "link" => links },
      request: nil,
    )

    assert_equal(
      {
        last: "projects?page=173",
        next: "projects?page=6",
      },
      response.pagination,
    )
  end

  def test_response_pagination_no_links
    response = Procore::Response.new(
      body: [{ key: "value" }].to_json,
      code: 200,
      headers: {
        "link" => "",
      },
      request: nil,
    )

    assert_equal({}, response.pagination)
  end
end
