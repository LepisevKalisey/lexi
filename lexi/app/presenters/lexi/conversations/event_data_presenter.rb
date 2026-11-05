# Adds the SLA card data (applied SLA and missed targets) to conversation events, the same
# fields the conversation JSON carries through lexi/api/v1/conversations/partials/_conversation.
module Lexi::Conversations::EventDataPresenter
  def push_data
    super.merge(Sla::ConversationPayload.new(__getobj__).to_h)
  end
end
