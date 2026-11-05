# Inboxes and conversations are deleted in this job. The controller passes the user who asked for
# it and their address, and the deletion is recorded with them in the account's audit log. Records
# deleted along with them (an inbox's conversations, an account's inboxes) are not recorded one by
# one.
module Lexi::DeleteObjectJob
  # A deleted conversation is recorded by its identifiers only, not by what it held.
  CONVERSATION_ATTRIBUTES = %w[id display_id inbox_id contact_id assignee_id team_id status].freeze

  def process_post_deletion_tasks(object, user, ip)
    super
    return unless object.is_a?(::Inbox) || object.is_a?(::Conversation)

    Lexi::AuditLog.create!(auditable: object, associated: object.account, action: 'destroy', user: user,
                           remote_address: ip, audited_changes: deleted_attributes(object))
  end

  private

  def deleted_attributes(object)
    return object.attributes.slice(*CONVERSATION_ATTRIBUTES) if object.is_a?(::Conversation)

    object.attributes
  end
end
