# Records a sign-in or sign-out in the audit log of every account of the user with one INSERT.
# Audit callbacks do not run for it, so what they would set is set here, and the location of the
# address is looked up once for the whole batch. A lookup that cannot be queued does not stop the
# sign-in or sign-out.
class Lexi::AuditLogs::SessionEventService
  pattr_initialize [:user!, :action!, :remote_address, :request_uuid]

  def perform
    account_ids = user.account_users.order(:id).pluck(:account_id)
    return if account_ids.empty?

    audit_log_ids = Lexi::AuditLog.insert_all(rows(account_ids), returning: :id).pluck('id') # rubocop:disable Rails/SkipsModelValidations
    enqueue_ip_lookup(audit_log_ids, account_ids)
  end

  private

  def rows(account_ids)
    last_version = Lexi::AuditLog.where(auditable_type: 'User', auditable_id: user.id).maximum(:version).to_i
    created_at = Time.current
    uuid = request_uuid.presence || SecureRandom.uuid

    account_ids.each_with_index.map do |account_id, index|
      {
        auditable_type: 'User', auditable_id: user.id, associated_type: 'Account', associated_id: account_id,
        user_type: 'User', user_id: user.id, username: user.email, action: action, version: last_version + index + 1,
        remote_address: remote_address, request_uuid: uuid, created_at: created_at
      }
    end
  end

  def enqueue_ip_lookup(audit_log_ids, account_ids)
    return if remote_address.blank? || !Account.where(id: account_ids).feature_ip_lookup.exists?

    Lexi::AuditLogSessionIpLookupJob.perform_later(audit_log_ids, remote_address)
  rescue StandardError => e
    Rails.logger.warn "Audit log #{action} of user #{user.id}: IP lookup not queued: #{e.message}"
  end
end
