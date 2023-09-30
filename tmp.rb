# frozen_string_literal: true

require_relative 'lib/redmine_amzn_alb_authn'

jwt = gets.chomp

decoder = RedmineAmznALBAuthn::OIDCDataDecoder.new(
  key_endpoint: 'https://public-keys.auth.elb.ap-northeast-1.amazonaws.com/',
)
p, h = decoder.verify_and_decode!(jwt)

pp h
pp p
