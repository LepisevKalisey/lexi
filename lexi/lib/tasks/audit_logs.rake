namespace :audit_logs do
  desc 'Look up the city and country of audit records that have none (accounts with ip_lookup on)'
  task backfill_ip_locations: :environment do
    Lexi::AuditLogIpLocationBackfillJob.perform_later
    puts 'Queued Lexi::AuditLogIpLocationBackfillJob; it runs in the low queue batch by batch.'
  end
end
