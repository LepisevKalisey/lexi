# Location of the address of a sign-in or sign-out: looked up once for all the records the event
# wrote, and set on those of accounts with ip_lookup on.
class Lexi::AuditLogSessionIpLookupJob < ApplicationJob
  queue_as :low

  def perform(audit_log_ids, remote_address)
    return if remote_address.blank?

    audit_logs = Lexi::AuditLog.where(id: audit_log_ids, associated_type: 'Account',
                                      associated_id: Account.feature_ip_lookup.select(:id))
    return unless audit_logs.exists?

    Lexi::AuditLogs::IpLocationService.new(remote_address).apply_to(audit_logs)
  end
end
