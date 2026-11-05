class AppliedSlaPolicy < ApplicationPolicy
  include Lexi::CustomRolePermissions

  %i[index? metrics? download?].each do |action|
    define_method(action) { @account_user.administrator? || custom_role_permission?('report_manage') }
  end
end
