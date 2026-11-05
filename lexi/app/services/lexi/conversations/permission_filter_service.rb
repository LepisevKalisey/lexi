# Conversation lists for an agent with a custom role, inside the inboxes the agent belongs to:
# all of them (conversation_manage), unassigned ones and their own (conversation_unassigned_manage),
# or their own and those they take part in (conversation_participating_manage). The widest
# granted permission wins. Same rules as Lexi::ConversationPolicy#show?.
module Lexi::Conversations::PermissionFilterService
  def perform
    permissions = custom_role_permissions
    return super if permissions.nil?

    filter_by_custom_role(accessible_conversations, permissions)
  end

  private

  def custom_role_permissions
    current_account_user = account_user
    return if current_account_user.nil? || current_account_user.administrator?

    current_account_user.custom_role&.permissions
  end

  def filter_by_custom_role(scope, permissions)
    return scope if permissions.include?('conversation_manage')

    own = scope.where(assignee_id: user.id)
    return own.or(scope.where(assignee_id: nil, assignee_agent_bot_id: nil)) if permissions.include?('conversation_unassigned_manage')
    return own.or(scope.where(id: ConversationParticipant.where(user_id: user.id).select(:conversation_id))) if participating?(permissions)

    scope.none
  end

  def participating?(permissions)
    permissions.include?('conversation_participating_manage')
  end
end
