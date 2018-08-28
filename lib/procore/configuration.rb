require "procore/defaults"

module Procore
  # Yields the configuration so the end user can set multiple attributes at
  # once.
  #
  # @example Within config/initializers/procore.rb
  #   Procore.configure do |config|
  #     config.timeout = 5.0
  #     config.user_agent = MyApp
  #   end
  def self.configure
    yield(configuration)
  end

  # The current configuration for the gem.
  #
  # @return [Configuration]
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Holds the configuration for the Procore gem.
  class Configuration
    # @!attribute [rw] host
    # @note defaults to Defaults::API_ENDPOINT
    #
    # Base API host name. Alter this depending on your environment - in a
    # staging or test environment you may want to point this at a sandbox
    # instead of production.
    #
    # @return [String]
    attr_accessor :host

    # @!attribute [rw] auth_host
    # @note defaults to Defaults::AUTH_HOST
    #
    # Base authentication host name. Alter this depending on your environment - in a
    # staging or test environment you may want to point this at a sandbox
    # instead of production.
    #
    # @return [String]
    attr_accessor :auth_host

    # @!attribute [rw] logger
    # @note defaults to nil
    #
    # Instance of a Logger. This gem will log information about requests,
    # responses and other things it might be doing. In a Rails application it
    # should be set to Rails.logger
    #
    # @return [Logger, nil]
    attr_accessor :logger

    # @!attribute [rw] max_retries
    # @note Defaults to 1
    #
    # Number of times to retry a failed API call. Reasons an API call
    # could potentially fail:
    # 1. Service is briefly down or unreachable
    # 2. Timeout hit - service is experiencing immense load or mid restart
    # 3. Because computers
    #
    # Would recommend 3-5 for production use. Has exponential backoff - first
    # request waits a 1.5s after a failure, next one 2.25s, next one 3.375s,
    # 5.0, etc.
    #
    # @return [Integer]
    attr_accessor :max_retries

    # @!attribute [rw] timeout
    # @note defaults to 1.0
    #
    # Threshold for canceling an API request. If a request takes longer
    # than this value it will automatically cancel.
    #
    # @return [Float]
    attr_accessor :timeout

    # @!attribute [rw] user_agent
    # @note defaults to Defaults::USER_AGENT
    #
    # User Agent sent with each API request. API requests must have a user
    # agent set. It is recomended to set the user agent to the name of your
    # application.
    #
    # @return [String]
    attr_accessor :user_agent

    def initialize
      @host = Procore::Defaults::API_ENDPOINT
      @auth_host = Procore::Defaults::AUTH_HOST
      @logger = nil
      @max_retries = 1
      @timeout = 1.0
      @user_agent = Procore::Defaults::USER_AGENT
    end
  end
end
