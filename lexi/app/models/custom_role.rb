# A set of permissions an agent works with instead of the agent role. Changing the permissions,
# or removing the role, changes which conversations its users see, so their filtered unread
# counts are recomputed.
class CustomRole < ApplicationRecord
  include Events::Types

  PERMISSIONS = %w[
    conversation_manage
    conversation_unassigned_manage
    conversation_participating_manage
    contact_manage
    report_manage
    knowledge_base_manage
  ].freeze

  belongs_to :account
  has_many :account_users, dependent: :nullify

  validates :name, presence: true
  validate :permissions_are_known

  before_destroy :remember_user_ids, prepend: true
  after_update_commit :users_visibility_changed, if: :saved_change_to_permissions?
  after_destroy_commit :users_visibility_changed

  private

  def permissions_are_known
    unknown = Array(permissions) - PERMISSIONS
    errors.add(:permissions, "unknown: #{unknown.join(', ')}") if unknown.any?
  end

  def remember_user_ids
    @user_ids = account_users.pluck(:user_id)
  end

  def users_visibility_changed
    user_ids = @user_ids || account_users.pluck(:user_id)
    return if user_ids.empty?

    ::Conversations::UnreadCounts::FilteredCountInvalidator.new(account).users_visibility_changed!(user_ids: user_ids)
    Rails.configuration.dispatcher.dispatch(ACCOUNT_CACHE_INVALIDATED, Time.zone.now, account: account, cache_keys: account.cache_keys)
  end
end
