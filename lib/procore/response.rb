require "active_support/hash_with_indifferent_access"

module Procore
  # Wrapper class for a response received from the Procore API. Stores the
  # body, code, headers, and pagination information.
  #
  # @example Getting the details about the response.
  #   response = client.get("projects")
  #   response.body #=> [{ id: 5, name: "Project 5" }]
  #   response.code #=> 200
  #
  # When a response returns a collection of elements, a Link Header is included
  # in the response. This header contains one or more URLs that can be used to
  # access more results.
  #
  # The possible values for pagination are:
  #
  #   next  URL for the immediate next page of results.
  #   last  URL for the last page of results.
  #   first URL for the first page of results.
  #   prev  URL for the immediate previous page of results.
  #
  # @example Using pagination
  #   first_page = client.get("projects")
  #
  #   # The first page will only have URLs for :next & :last
  #   first_page.pagination[:first]
  #     #=> nil
  #   first_page.pagination[:next]
  #     #=> "projects?per_page=20&page=2"
  #
  #   # Any other page will have all keys
  #   next_page = client.get(first_page.pagination[:next])
  #   next_page.pagination[:first]
  #     #=> "projects?per_page=20&page=1"
  #
  #   # The last page will only have URLs for :first & :next
  #   last_page = client.get(first_page.pagination[:last])
  #   last_page.pagination[:last]
  #     #=> nil
  class Response
    # @!attribute [r] headers
    #   @return [Hash<String, String>] Raw headers returned from Procore API.
    # @!attribute [r] code
    #   @return [Integer] Status Code returned from Procore API.
    # @!attribute [r] pagination
    #   @return [Hash<Symbol, String>] Pagination URLs
    attr_reader :headers, :code, :pagination, :request, :request_body

    def initialize(body:, headers:, code:, request:, request_body:)
      @code = code
      @headers = headers
      @pagination = parse_pagination
      @request = request
      @request_body = request_body
      @raw_body = !body.to_s.empty? ? body : "{}".to_json
    end

    # @return [Array<Hash>, Hash] Ruby representation of JSON response. Hashes are
    #   with indifferent access
    def body
      @body ||= parse_body
    end

    private

    attr_reader :raw_body

    def parse_body
      JSON.parse(raw_body, object_class: HashWithIndifferentAccess)
    end

    def parse_pagination
      headers[:link].to_s.split(", ").map(&:strip).reduce({}) do |links, link|
        url, name = link.match(/vapid\/(.*?)>; rel="(\w+)"/).captures
        links.merge!(name.to_sym => url)
      end
    end
  end
end
