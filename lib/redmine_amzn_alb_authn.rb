# frozen_string_literal: true

require_relative 'redmine_amzn_alb_authn/application_controller_patch'

# Plugin namespace and configuration store.
module RedmineAmznALBAuthn
  def self.aws_region
    @aws_region ||= ENV.fetch('REDMINE_AMZN_ALB_AUTHN_REGION', 'ap-northeast-1')
  end
end
