json.audit_logs @audit_logs do |audit_log|
  json.partial! 'api/v1/models/audit_log', formats: [:json], audit_log: audit_log, full_ip_address: @full_ip_addresses
end
json.current_page @audit_logs.current_page
json.per_page @audit_logs.limit_value
json.total_entries @audit_logs.total_count
