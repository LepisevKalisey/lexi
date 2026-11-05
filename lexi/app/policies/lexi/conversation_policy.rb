# Which conversations an agent with a custom role may open, within the inboxes and teams the
# agent belongs to: all of them (conversation_manage), unassigned ones and their own
# (conversation_unassigned_manage), or their own and those they take part in
# (conversation_participating_manage). The widest granted permission wins.
module Lexi::ConversationPolicy
  include Lexi::CustomRolePermissions

  def show?
    return super if account_user&.custom_role.nil? || administrator? || agent_bot?

    agent_can_view_conversation? && custom_role_can_view_conversation?
  end

  private

  def custom_role_can_view_conversation?
    return true if custom_role_permission?('conversation_manage')
    return assigned_to_user? || unassigned? if custom_role_permission?('conversation_unassigned_manage')
    return assigned_to_user? || participant? if custom_role_permission?('conversation_participating_manage')

    false
  end

  def unassigned?
    record.assignee_id.nil? && record.assignee_agent_bot_id.nil?
  end
end
