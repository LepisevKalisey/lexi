# Loaded only by the upstream acceptance run (lexi-ci: rspec --require). A few upstream specs
# name Chatwoot Enterprise constants; LEXI implements the same behaviour under Lexi::. Production
# code never defines Enterprise.
require 'rails_helper'

module Enterprise
  module Conversations; end
end

{
  'Enterprise::Conversations::PermissionFilterService' => 'Lexi::Conversations::PermissionFilterService',
  'Enterprise::AuditLog' => 'Lexi::AuditLog',
  'Enterprise::AuditLogIpLookupJob' => 'Lexi::AuditLogIpLookupJob'
}.each do |alias_name, lexi_name|
  lexi_constant = lexi_name.safe_constantize
  next if lexi_constant.nil?

  namespace, _, constant_name = alias_name.rpartition('::')
  namespace.constantize.const_set(constant_name, lexi_constant)
end
