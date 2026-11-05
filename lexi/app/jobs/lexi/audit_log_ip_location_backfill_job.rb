# Looks up the location of audit records that have none, such as those written before their
# account turned ip_lookup on. Works a batch at a time in id order; each run queues the next one
# after the last id it took, and the chain ends when nothing is left.
class Lexi::AuditLogIpLocationBackfillJob < ApplicationJob
  queue_as :low

  BATCH_SIZE = 500

  def perform(after_id = 0)
    batch = unresolved_audit_logs.where(id: (after_id + 1)..).order(:id).limit(BATCH_SIZE).pluck(:id, :remote_address)
    return if batch.empty?

    batch.group_by(&:last).each do |remote_address, rows|
      Lexi::AuditLogs::IpLocationService.new(remote_address).apply_to(Lexi::AuditLog.where(id: rows.map(&:first)))
    end
    self.class.perform_later(batch.last.first)
  end

  private

  def unresolved_audit_logs
    Lexi::AuditLog.where.not(remote_address: [nil, ''])
                  .where(city: nil, country: nil)
                  .where(associated_type: 'Account', associated_id: Account.feature_ip_lookup.select(:id))
  end
end
