# Knowledge base editors manage portals they are given; creating and deleting portals stays
# with administrators.
module Lexi::PortalPolicy
  include Lexi::CustomRolePermissions

  %i[update? edit? logo?].each do |action|
    define_method(action) { super() || custom_role_permission?('knowledge_base_manage') }
  end
end
