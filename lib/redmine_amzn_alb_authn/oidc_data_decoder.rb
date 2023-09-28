# frozen_string_literal: true

require 'net/http'
require 'active_support'
require 'active_support/core_ext/numeric/time'
require 'jwt'

module RedmineAmznALBAuthn
  # Verifies and decodes the JWT from the X-Amzn-Oidc-Data header sent by ALB.
  class OIDCDataDecoder
    def initialize(oidc_data)
      @oidc_data = oidc_data
    end

    def self.key_cache
      @key_cache ||= ActiveSupport::Cache::MemoryStore.new(expires_in: 1.hour)
    end

    def verify_and_decode!
      JWT.decode(@oidc_data, nil, true, algorithm: 'ES256') do |header|
        key_str = self.class.key_cache.fetch(header.fetch('kid')) do
          key_uri = URI("https://public-keys.auth.elb.#{RedmineAmznALBAuthn.aws_region}.amazonaws.com/#{header['kid']}")
          key_response = Net::HTTP.get_response(key_uri)
          key_response.value
          key_response.body
        end
        OpenSSL::PKey::EC.new(key_str)
      end
    end
  end
end
