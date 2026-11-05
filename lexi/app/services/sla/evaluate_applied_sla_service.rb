# Checks one applied SLA against its conversation and records what was missed.
#
# - First response (frt): missed when the first reply came, or still has not come, after its
#   deadline. Recorded once.
# - Next response (nrt): checked while the contact waits after the first reply. Recorded once
#   per incoming message, so a contact who writes again after a miss starts a new count.
# - Resolution (rt): checked while the conversation is open. Recorded once.
#
# A resolved conversation completes the SLA: hit without misses, missed with any.
# Blocked contacts are left out of SLA tracking altogether.
class Sla::EvaluateAppliedSlaService
  pattr_initialize [:applied_sla!]

  def perform
    return unless conversation.sla_applicable?

    check_first_response
    check_next_response
    check_resolution
    complete if conversation.resolved?
  end

  private

  delegate :conversation, :sla_policy, :account, to: :applied_sla

  def check_first_response
    due_at = applied_sla.frt_due_at
    return if due_at.nil? || event_recorded?(:frt)

    replied_at = conversation.first_reply_created_at
    missed = replied_at ? replied_at.to_i > due_at : Time.current.to_i > due_at
    record_miss(:frt) if missed
  end

  def check_next_response
    return if conversation.resolved? || conversation.first_reply_created_at.blank?

    due_at = applied_sla.nrt_due_at
    return if due_at.nil? || Time.current.to_i <= due_at

    message = conversation.messages.incoming.reorder(created_at: :desc, id: :desc).first
    meta = { 'message_id' => message&.id }
    return if applied_sla.sla_events.nrt.exists?(['meta @> ?', meta.to_json])

    record_miss(:nrt, meta)
  end

  # A conversation resolved before this run is judged by its earlier runs: a run catches a
  # resolution miss while the conversation is still open.
  def check_resolution
    return if conversation.resolved?

    due_at = applied_sla.rt_due_at
    return if due_at.nil? || Time.current.to_i <= due_at || event_recorded?(:rt)

    record_miss(:rt)
  end

  def complete
    if applied_sla.sla_events.exists?
      applied_sla.update!(sla_status: :missed, completed_at: applied_sla.completed_at || Time.current)
    else
      applied_sla.update!(sla_status: :hit, completed_at: applied_sla.completed_at || Time.current)
      Rails.logger.info "SLA hit for conversation #{conversation.id} in account #{applied_sla.account_id} for sla_policy #{sla_policy.id}"
    end
  end

  def record_miss(event_type, meta = {})
    Rails.logger.warn "SLA #{event_type} missed for conversation #{conversation.id} in account " \
                      "#{applied_sla.account_id} for sla_policy #{sla_policy.id}"
    applied_sla.sla_events.create!(event_type: event_type, conversation: conversation, meta: meta)
    applied_sla.update!(sla_status: :active_with_misses) if applied_sla.active?
  end

  def event_recorded?(event_type)
    applied_sla.sla_events.where(event_type: event_type).exists?
  end
end
