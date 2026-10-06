# frozen_string_literal: true

# Super admin: per-account feature flags on the account page. Chatwoot ships this field only
# in enterprise/, so a Community install has no way to switch features for an account.
module Lexi::AccountDashboard
  def attribute_types
    super.merge(all_features: Lexi::AccountFeatureFlagsField)
  end

  def show_page_attributes
    super + [:all_features]
  end

  def form_attributes(action = nil)
    super + [:all_features]
  end
end
