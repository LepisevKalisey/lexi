# Changes of users themselves (profile, password, tokens) are not audited. Their sign-ins and
# sign-outs are (Lexi::AuditLogs::SessionEventService), and these are the user's audits.
module Lexi::Audit::User
  extend ActiveSupport::Concern

  included do
    # dependent: nil: the audit log outlives the user.
    has_many :audits, -> { order(version: :asc) }, as: :auditable, class_name: 'Lexi::AuditLog',
                                                    inverse_of: :auditable, dependent: nil
  end
end
