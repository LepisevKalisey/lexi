# Changes of the account's settings go to its own audit log, which also holds the audits of the
# records it owns (associated_audits).
module Lexi::Audit::Account
  extend ActiveSupport::Concern

  included do
    audited associated_with: :itself, on: [:update], except: %i[internal_attributes]
    has_associated_audits
  end
end
