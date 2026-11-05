# A message an agent deletes is recorded in the account's audit log together with the text it
# had; the audit log API does not return that text. Deleting a message that is already deleted
# records nothing.
module Lexi::Api::V1::Accounts::Conversations::MessagesController
  def destroy
    deleted_message = message
    already_deleted = deleted_message.deleted?
    original_content = deleted_message.content
    super
    record_message_deletion(deleted_message, original_content) unless already_deleted
  end

  private

  def record_message_deletion(deleted_message, original_content)
    Lexi::AuditLog.create!(
      auditable: deleted_message, associated: Current.account, action: 'destroy',
      audited_changes: { 'content' => original_content, 'conversation_id' => deleted_message.conversation_id,
                         'display_id' => @conversation.display_id, 'inbox_id' => deleted_message.inbox_id }
    )
  rescue StandardError => e
    ChatwootExceptionTracker.new(e, account: Current.account).capture_exception
  end
end
