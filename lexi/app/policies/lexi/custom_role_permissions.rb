# Permission checks of a custom role for the LEXI policy modules. Administrators keep their
# own checks; an agent without a custom role is not affected.
module Lexi::CustomRolePermissions
  private

  def custom_role_permissions
    return [] if @account_user.nil? || @account_user.administrator?

    @account_user.custom_role&.permissions || []
  end

  def custom_role_permission?(permission)
    custom_role_permissions.include?(permission)
  end
end
