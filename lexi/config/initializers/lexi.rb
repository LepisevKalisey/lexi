# frozen_string_literal: true

# Core classes without a prepend_mod_with extension point get their LEXI module here.
# Classes with one receive Lexi::<ClassName> through ChatwootApp.extensions instead.
Rails.application.config.to_prepare do
  next if ChatwootApp.enterprise?

  # Audit records are Lexi::AuditLog (the core initializer names the Enterprise class). Set before
  # anything loads an audited model, and again on every reload so the class is never a stale one.
  Audited.config { |config| config.audit_class = 'Lexi::AuditLog' }

  DashboardController.prepend(Lexi::DashboardController)
  AccountDashboard.prepend(Lexi::AccountDashboard)
end
