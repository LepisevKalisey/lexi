# SLA fields of a conversation for the dashboard (conversation JSON and cable events): empty
# unless the account has the sla feature and the contact is not blocked.
class Sla::ConversationPayload
  def initialize(conversation)
    @conversation = conversation
  end

  def to_h
    return {} unless @conversation.account.feature_enabled?('sla') && @conversation.sla_applicable?

    {
      applied_sla: @conversation.applied_sla&.push_event_data,
      sla_events: @conversation.sla_events.order(:created_at).map(&:push_event_data)
    }
  end
end
