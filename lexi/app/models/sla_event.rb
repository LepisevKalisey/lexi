# One missed SLA target: first response (frt), next response (nrt) or resolution (rt).
# The assignee, the participants and the account administrators are notified.
class SlaEvent < ApplicationRecord
  belongs_to :account
  belongs_to :inbox
  belongs_to :conversation
  belongs_to :sla_policy
  belongs_to :applied_sla

  enum event_type: { frt: 0, nrt: 1, rt: 2 }

  NOTIFICATION_TYPES = {
    'frt' => 'sla_missed_first_response',
    'nrt' => 'sla_missed_next_response',
    'rt' => 'sla_missed_resolution'
  }.freeze

  before_validation :backfill_ids, on: :create
  after_create_commit :notify_users

  def push_event_data
    {
      id: id,
      event_type: event_type,
      meta: meta,
      created_at: created_at.to_i,
      updated_at: updated_at.to_i
    }
  end

  private

  def backfill_ids
    self.account_id = conversation.account_id if conversation
    self.inbox_id = conversation.inbox_id if conversation
    self.sla_policy_id = applied_sla.sla_policy_id if applied_sla
  end

  def notify_users
    recipients.each do |user|
      NotificationBuilder.new(
        notification_type: NOTIFICATION_TYPES.fetch(event_type),
        user: user,
        account: account,
        primary_actor: conversation,
        secondary_actor: self
      ).perform
    end
  end

  def recipients
    ([conversation.assignee] + conversation.conversation_participants.map(&:user) + account.administrators).compact.uniq
  end
end
