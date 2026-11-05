# Location of the address an audit record was written from.
class Lexi::AuditLogIpLookupJob < ApplicationJob
  queue_as :low

  def perform(audit_log)
    return if audit_log.remote_address.blank?

    Lexi::AuditLogs::IpLocationService.new(audit_log.remote_address).apply_to(Lexi::AuditLog.where(id: audit_log.id))
  end
end
