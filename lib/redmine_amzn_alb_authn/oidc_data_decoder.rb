# frozen_string_literal: true

require 'net/http'

require 'active_support'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/numeric/time'
require 'jwt'

require_relative 'errors'

module RedmineAmznAlbAuthn
  # Verifies and decodes the JWT from the X-Amzn-Oidc-Data header sent by ALB.
  class OidcDataDecoder
    class_attribute :key_cache, default: ActiveSupport::Cache::MemoryStore.new(expires_in: 1.hour)

    def initialize(key_endpoint:, alb_arn:, iss: nil)
      @key_endpoint = key_endpoint
      @alb_arn = alb_arn
      @iss = iss
    end

    def verify_and_decode!(oidc_data)
      payload, header = JWT.decode(oidc_data, nil, true, algorithm: 'ES256', iss: @iss, verify_iss: true) do |header|
        key_str = key_cache.fetch(header.fetch('kid')) do
          key_uri = URI.join(@key_endpoint, header['kid'])
          key_response = Net::HTTP.get_response(key_uri)
          key_response.value
          key_response.body
        end
        OpenSSL::PKey::EC.new(key_str)
      end

      raise InvalidSignerError, "Invalid signer: #{header['signer']}" if header['signer'] != @alb_arn

      [payload, header]
    end
  end
end
