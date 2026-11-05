# Adding an agent to a team and removing them, in the audit log of the team's account.
module Lexi::Audit::TeamMember
  extend ActiveSupport::Concern

  included do
    audited associated_with: :audited_account, on: %i[create destroy]
  end

  private

  def audited_account
    team&.account
  end
end
