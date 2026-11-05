# auditable is reduced to the ids the audit log screen reads. A deleted message is returned
# without the message and without the text it had.
deleted_message = audit_log.auditable_type == 'Message'
auditable = audit_log.auditable unless deleted_message

json.id audit_log.id
json.action audit_log.action
json.auditable_type audit_log.auditable_type
json.auditable_id audit_log.auditable_id
json.auditable auditable && { id: auditable.id, user_id: auditable.try(:user_id) }.compact
json.associated_type audit_log.associated_type
json.associated_id audit_log.associated_id
json.user_type audit_log.user_type
json.user_id audit_log.user_id
json.username audit_log.username
json.audited_changes deleted_message ? audit_log.audited_changes&.except('content') : audit_log.audited_changes
json.version audit_log.version
json.comment audit_log.comment
json.request_uuid audit_log.request_uuid
json.created_at audit_log.created_at.to_i
json.remote_address full_ip_address ? audit_log.remote_address : audit_log.masked_remote_address
json.location audit_log.location
