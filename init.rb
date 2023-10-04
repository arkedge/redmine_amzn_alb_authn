# frozen_string_literal: true

require_relative 'lib/redmine_amzn_alb_authn'

Redmine::Plugin.register :redmine_amzn_alb_authn do
  name 'Amazon ALB authentication plugin'
  author 'Takahiro Miyoshi'
  description 'Use Amazon ALB for user authentication'
  version '0.1.2'
  url 'https://github.com/arkedge/redmine_amzn_alb_auth'
  author_url 'https://github.com/sankichi92'
end

RedmineAmznAlbAuthn.key_endpoint = ENV.fetch('REDMINE_AMZN_ALB_AUTHN_KEY_ENDPOINT')
RedmineAmznAlbAuthn.iss = ENV.fetch('REDMINE_AMZN_ALB_AUTHN_ISS', nil)

ApplicationController.prepend(RedmineAmznAlbAuthn::ApplicationControllerPatch)
