# frozen_string_literal: true

# Core classes without a prepend_mod_with extension point get their LEXI module here.
# Classes with one receive Lexi::<ClassName> through ChatwootApp.extensions instead.
Rails.application.config.to_prepare do
  next if ChatwootApp.enterprise?

  DashboardController.prepend(Lexi::DashboardController)
  AccountDashboard.prepend(Lexi::AccountDashboard)
end

# Audit records are Lexi::AuditLog (the core initializer names the Enterprise class).
Audited.config { |config| config.audit_class = 'Lexi::AuditLog' } unless ChatwootApp.enterprise?
