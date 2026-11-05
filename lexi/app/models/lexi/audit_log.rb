# The audit record of LEXI (Audited.config.audit_class). Secret values (the keys Rails filters from
# logs) never reach the table, and the user's email is kept with the record, so it stays readable
# after the user is deleted. The city and country of the address are looked up in the background
# when the account has ip_lookup on; the address itself is shown in full only to accounts with
# audit_log_ip_address.
class Lexi::AuditLog < Audited::Audit
  FILTERED = '[FILTERED]'.freeze
  # Keys the log filter patterns match (_key, auth) that hold no secret: the attribute of an
  # automation condition, the SMTP and IMAP authentication method.
  NOT_SECRET_KEYS = %w[attribute_key smtp_authentication imap_authentication].freeze

  before_create :drop_secret_changes, :set_username
  after_create_commit :enqueue_ip_lookup

  # Changes without secrets: a secret attribute is left out, a secret key inside a JSON value is
  # masked.
  def self.without_secrets(changes)
    changes.to_h.reject { |key, _| secret_key?(key) }.transform_values { |value| mask_secrets(value) }
  end

  def self.mask_secrets(value)
    case value
    when Hash then value.to_h { |key, nested| [key, secret_key?(key) ? FILTERED : mask_secrets(nested)] }
    when Array then value.map { |nested| mask_secrets(nested) }
    else value
    end
  end

  def self.secret_key?(key)
    NOT_SECRET_KEYS.exclude?(key.to_s) && secret_filter.filter_param(key.to_s, true) != true
  end

  def self.secret_filter
    @secret_filter ||= ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
  end

  def location
    [city, country].compact_blank.join(', ').presence
  end

  # IPv4: the last octet hidden; IPv6: the first four hextets of the full form kept, so host bits
  # never show.
  def masked_remote_address
    return if remote_address.blank?

    ip = IPAddr.new(remote_address)
    return "#{ip.to_s.split('.').first(3).join('.')}.x" if ip.ipv4?

    "#{ip.to_string.split(':').first(4).join(':')}::"
  rescue IPAddr::Error
    nil
  end

  private

  def drop_secret_changes
    self.audited_changes = self.class.without_secrets(audited_changes) if audited_changes.is_a?(Hash)
  end

  def set_username
    self.username ||= user.email if user.is_a?(::User)
  end

  def enqueue_ip_lookup
    return if remote_address.blank?
    return unless associated.is_a?(::Account) && associated.feature_enabled?('ip_lookup')

    Lexi::AuditLogIpLookupJob.perform_later(self)
  rescue StandardError => e
    Rails.logger.warn "Audit log #{id}: IP lookup not queued: #{e.message}"
  end
end
