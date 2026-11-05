module Lexi::Concerns::AccountUser
  extend ActiveSupport::Concern

  included do
    belongs_to :custom_role, optional: true
    validate :custom_role_of_the_account
  end

  private

  def custom_role_of_the_account
    return if custom_role.nil? || custom_role.account_id == account_id

    errors.add(:custom_role, 'must belong to the same account')
  end
end
