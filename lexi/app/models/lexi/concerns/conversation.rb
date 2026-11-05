# Conversation side of SLA: the policy a conversation runs under and what happened to it.
# Setting a policy applies it, once per policy.
module Lexi::Concerns::Conversation
  extend ActiveSupport::Concern

  included do
    belongs_to :sla_policy, optional: true
    has_one :applied_sla, -> { order(created_at: :desc) }, dependent: :destroy, inverse_of: :conversation
    has_many :sla_events, dependent: :destroy

    after_save :apply_sla_policy, if: -> { saved_change_to_sla_policy_id? && sla_policy_id.present? }
  end

  # Blocked contacts are left out of SLA tracking.
  def sla_applicable?
    !contact&.blocked?
  end

  private

  def apply_sla_policy
    AppliedSla.find_or_create_by!(account_id: account_id, sla_policy_id: sla_policy_id, conversation_id: id)
    association(:applied_sla).reset
  end
end
