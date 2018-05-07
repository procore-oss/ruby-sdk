require "rest-client"

module Procore
  # Module which defines HTTP verbs GET, POST, PUT, PATCH and DELETE. Is
  # included in Client. Has support for Idempotency Tokens on POST and PATCH.
  #
  # @example Using #get:
  #   client.get("my_open_items", per_page: 5)
  #
  # @example Using #post:
  #   client.post("projects", name: "New Project")
  module Requestable
    # @param path [String] URL path
    # @param query [Hash] Query options to pass along with the request
    # @option options [Hash] :company_id
    #
    # @example Usage
    #   client.get("my_open_items", query: { per_page: 5, filter: {} })
    #
    # @return [Response]
    def get(path, query: {}, options: {})
      full_path = File.join(base_api_path, path).to_s

      Util.log_info(
        "API Request Initiated",
        path: full_path,
        method: "GET",
        query: query.to_s,
      )

      with_response_handling do
        RestClient::Request.execute(
          method: :get,
          url: full_path,
          headers: headers(options).merge(params: query),
          timeout: Procore.configuration.timeout,
        )
      end
    end

    # @param path [String] URL path
    # @param body [Hash] Body parameters to send with the request
    # @param options [Hash} Extra request options
    # @option options [String] :idempotency_token | :company_id
    #
    # @example Usage
    #   client.post(
    #     "users",
    #     body: { name: "New User" },
    #     options: { idempotency_token: "key", company_id: 1 },
    #   )
    #
    # @return [Response]
    def post(path, body: {}, options: {})
      full_path = File.join(base_api_path, path).to_s

      Util.log_info(
        "API Request Initiated",
        path: full_path,
        method: "POST",
        body: body.to_s,
      )

      with_response_handling(request_body: body) do
        RestClient::Request.execute(
          method: :post,
          url: full_path,
          payload: payload(body),
          headers: headers(options),
          timeout: Procore.configuration.timeout,
        )
      end
    end

    # @param path [String] URL path
    # @param body [Hash] Body parameters to send with the request
    # @param options [Hash} Extra request options
    # @option options [String] :idempotency_token | :company_id
    #
    # @example Usage
    #   client.put("dashboards/1/users", body: [1,2,3], options: { company_id: 1 })
    #
    # @return [Response]
    def put(path, body: {}, options: {})
      full_path = File.join(base_api_path, path).to_s

      Util.log_info(
        "API Request Initiated",
        path: full_path,
        method: "PUT",
        body: body.to_s,
      )

      with_response_handling(request_body: body) do
        RestClient::Request.execute(
          method: :put,
          url: full_path,
          payload: payload(body),
          headers: headers(options),
          timeout: Procore.configuration.timeout,
        )
      end
    end

    # @param path [String] URL path
    # @param body [Hash] Body parameters to send with the request
    # @param options [Hash} Extra request options
    # @option options [String] :idempotency_token | :company_id
    #
    # @example Usage
    #   client.patch(
    #     "users/1",
    #     body: { name: "Updated" },
    #     options: { idempotency_token: "key", company_id: 1 },
    #   )
    #
    # @return [Response]
    def patch(path, body: {}, options: {})
      full_path = File.join(base_api_path, path).to_s

      Util.log_info(
        "API Request Initiated",
        path: full_path,
        method: "PATCH",
        body: body.to_s,
      )

      with_response_handling(request_body: body) do
        RestClient::Request.execute(
          method: :patch,
          url: full_path,
          payload: payload(body),
          headers: headers(options),
          timeout: Procore.configuration.timeout,
        )
      end
    end

    # @param path [String] URL path
    # @param query [Hash] Query options to pass along with the request
    # @option options [String] :company_id
    #
    # @example Usage
    #   client.delete("users/1", query: {}, options: {})
    #
    # @return [Response]
    def delete(path, query: {}, options: {})
      full_path = File.join(base_api_path, path).to_s

      Util.log_info(
        "API Request Initiated",
        path: full_path,
        method: "DELETE",
        headers: headers(options),
        query: query.to_s,
      )

      with_response_handling do
        RestClient::Request.execute(
          method: :delete,
          url: full_path,
          headers: headers.merge(params: query),
          timeout: Procore.configuration.timeout,
        )
      end
    end

    private

    def with_response_handling(request_body: nil)
      request_start_time = Time.now
      retries = 0

      begin
        result = yield
      rescue RestClient::Exceptions::Timeout, Errno::ECONNREFUSED => e
        if retries <= Procore.configuration.max_retries
          retries += 1
          sleep 1.5**retries
          retry
        else
          raise APIConnectionError.new(
            "Cannot connect to the Procore API. Double check your timeout "    \
            "settings to ensure requests are not being cancelled before they " \
            "can complete. Try setting the timeout and max_retries to larger " \
            "values.",
          ), e
        end
      rescue RestClient::ExceptionWithResponse => e
        result = e.response
      end

      response = Procore::Response.new(
        body: result.body,
        headers: result.headers,
        code: result.code,
        request: result.request,
        request_body: request_body,
      )

      case result.code
      when 200..299
        Util.log_info(
          "API Request Finished ",
          path: result.request.url,
          status: result.code.to_s,
          duration: "#{((Time.now - request_start_time) * 1000).round(0)}ms",
          request_id: result.headers["x-request-id"],
        )
      else
        Util.log_error(
          "API Request Failed",
          path: result.request.url,
          status: result.code.to_s,
          duration: "#{((Time.now - request_start_time) * 1000).round(0)}ms",
          request_id: result.headers["x-request-id"],
          retries: retries,
        )
      end

      case result.code
      when 200..299
        response
      when 401
        raise Procore::AuthorizationError.new(
          "The request failed because you lack the correct credentials to "    \
          "access the target resource",
          response: response,
        )
      when 403
        raise Procore::ForbiddenError.new(
          "The request failed because you lack the required permissions",
          response: response,
        )
      when 404
        raise Procore::NotFoundError.new(
          "The URI requested is invalid or the resource requested does not "   \
          "exist.",
          response: response,
        )
      when 400, 422
        raise Procore::InvalidRequestError.new(
          "Bad Request.",
          response: response,
        )
      when 429
        raise Procore::RateLimitError.new(
          "You have surpassed the max number of requests for an hour. Please " \
          "wait until your limit resets.",
          response: response,
        )
      else
        raise Procore::ServerError.new(
          "Something is broken. This is usually a temporary error - Procore "  \
          "may be down or this endpoint may be having issues. Check "          \
          "http://status.procore.com for any known or ongoing issues.",
          response: response,
        )
      end
    end

    def headers(options = {})
      {
        "Accepts" => "application/json",
        "Authorization" => "Bearer #{access_token}",
        "Content-Type" => "application/json",
        "User-Agent" => Procore.configuration.user_agent,
      }.tap do |headers|
        if options[:idempotency_token]
          headers["Idempotency-Token"] = options[:idempotency_token]
        end

        if options[:company_id]
          headers["procore-company-id"] = options[:company_id]
        end
      end
    end

    def payload(body)
      if multipart?(body)
        body
      else
        body.to_json
      end
    end

    def multipart?(body)
      RestClient::Payload::has_file?(body)
    end
  end
end
