# frozen_string_literal: true

require 'active_support/core_ext/module/attribute_accessors'

require_relative 'redmine_amzn_alb_authn/application_controller_patch'

# Plugin namespace and configuration store.
module RedmineAmznAlbAuthn
  mattr_accessor :key_endpoint, :iss
end
