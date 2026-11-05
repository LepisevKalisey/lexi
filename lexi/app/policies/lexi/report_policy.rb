module Lexi::ReportPolicy
  include Lexi::CustomRolePermissions

  def view?
    super || custom_role_permission?('report_manage')
  end
end
