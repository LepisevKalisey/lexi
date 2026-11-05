module Lexi::ContactPolicy
  include Lexi::CustomRolePermissions

  def import?
    super || custom_role_permission?('contact_manage')
  end

  def export?
    super || custom_role_permission?('contact_manage')
  end
end
