# City and country of an address, from the GeoIP database the contact IP lookup uses, written to
# the given audit records. A failing lookup is logged and leaves the records as they are, so a
# flaky database does not fail the job that called it.
class Lexi::AuditLogs::IpLocationService
  pattr_initialize :remote_address

  def apply_to(audit_logs)
    result = IpLookupService.new.perform(remote_address)
    return if result.nil?

    audit_logs.update_all(city: result.city, country: result.country, country_code: result.country_code) # rubocop:disable Rails/SkipsModelValidations
  rescue StandardError => e
    Rails.logger.warn "Audit log IP lookup failed: #{e.message}"
  end
end
