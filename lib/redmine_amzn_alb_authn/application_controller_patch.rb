# frozen_string_literal: true

require_relative 'oidc_data_decoder'

module RedmineAmznALBAuthn
  # Module for monkey-patching Redmine's ApplicationController to override authentication.
  module ApplicationControllerPatch
    def find_current_user
      # Referred https://github.com/redmine/redmine/blob/5.0.5/app/controllers/application_controller.rb#L110-L163
      user = super
      return user if user

      user = find_user_by_amzn_alb_header

      user.remote_ip = request.remote_ip if user
      user
    end

    private

    def find_user_by_amzn_alb_header
      amzn_oidc_data = request.headers['X-Amzn-Oidc-Data']
      unless amzn_oidc_data
        logger.debug 'No X-Amzn-Oidc-Data header found in the request'
        return
      end

      decoder = OIDCDataDecoder.new(
        key_endpoint: RedmineAmznALBAuthn.key_endpoint,
        iss: RedmineAmznALBAuthn.iss,
      )
      begin
        payload, _header = decoder.verify_and_decode!(amzn_oidc_data)
      rescue JWT::DecodeError, Net::HTTPExceptions => e
        logger.error(e)
        return
      end

      email = payload['email']
      unless email
        logger.warn 'Payload of X-Amzn-Oidc-Data does not contain email'
        return
      end

      User.active.joins(:email_addresses).merge(EmailAddress.where(address: email)).take
    end
  end
end
