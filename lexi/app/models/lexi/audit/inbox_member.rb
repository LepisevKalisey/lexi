# Adding an agent to an inbox and removing them, in the audit log of the inbox's account.
module Lexi::Audit::InboxMember
  extend ActiveSupport::Concern

  included do
    audited associated_with: :audited_account, on: %i[create destroy]
  end

  private

  def audited_account
    inbox&.account
  end
end
