module Lexi::CsatSurveyResponsePolicy
  include Lexi::CustomRolePermissions

  %i[index? metrics? download?].each do |action|
    define_method(action) { super() || custom_role_permission?('report_manage') }
  end
end
