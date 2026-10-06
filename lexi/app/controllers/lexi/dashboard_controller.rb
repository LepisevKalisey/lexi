# frozen_string_literal: true

# The dashboard opens premium screens (SLA, custom roles, audit logs…) only on an enterprise
# installation whose plan is not "community"; the account feature flags decide the rest.
# LEXI reports itself that way to the frontend only. The stored plan stays as it is, because
# the backend reads it for features LEXI does not implement, such as the SAML login button.
module Lexi::DashboardController
  private

  def set_global_config
    super
    @global_config['IS_ENTERPRISE'] = true
    @global_config['INSTALLATION_PRICING_PLAN'] = Lexi::PLAN_NAME
  end
end
