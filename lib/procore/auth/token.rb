module Procore
  module Auth
    class Token
      attr_reader :access_token, :refresh_token, :expires_at
      def initialize(access_token:, refresh_token:, expires_at:)
        @access_token = access_token
        @refresh_token = refresh_token
        @expires_at = expires_at
      end

      def invalid?
        access_token.nil?
      end

      def expired?
        expires_at.to_i < Time.now.to_i
      end
    end
  end
end
