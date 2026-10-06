# frozen_string_literal: true

# Core classes without a prepend_mod_with extension point get their LEXI module here.
# Classes with one receive Lexi::<ClassName> through ChatwootApp.extensions instead.
Rails.application.config.to_prepare do
  next if ChatwootApp.enterprise?

  DashboardController.prepend(Lexi::DashboardController)
  AccountDashboard.prepend(Lexi::AccountDashboard)
end
