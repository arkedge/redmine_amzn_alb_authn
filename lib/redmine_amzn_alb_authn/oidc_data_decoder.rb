# frozen_string_literal: true

require 'net/http'

require 'active_support'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/numeric/time'
require 'jwt'

module RedmineAmznAlbAuthn
  # Verifies and decodes the JWT from the X-Amzn-Oidc-Data header sent by ALB.
  class OIDCDataDecoder
    class_attribute :key_cache, default: ActiveSupport::Cache::MemoryStore.new(expires_in: 1.hour)

    def initialize(key_endpoint:, iss: nil)
      @key_endpoint = key_endpoint
      @iss = iss
    end

    def verify_and_decode!(oidc_data)
      JWT.decode(oidc_data, nil, true, algorithm: 'ES256', iss: @iss, verify_iss: true) do |header|
        key_str = key_cache.fetch(header.fetch('kid')) do
          key_uri = URI.join(@key_endpoint, header['kid'])
          key_response = Net::HTTP.get_response(key_uri)
          key_response.value
          key_response.body
        end
        OpenSSL::PKey::EC.new(key_str)
      end
    end
  end
end
