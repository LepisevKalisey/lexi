module Lexi::CategoryPolicy
  include Lexi::CustomRolePermissions

  %i[index? update? show? edit? create? destroy? reorder?].each do |action|
    define_method(action) { super() || custom_role_permission?('knowledge_base_manage') }
  end
end
