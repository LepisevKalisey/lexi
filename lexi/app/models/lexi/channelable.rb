# Channel settings are part of an inbox's configuration, so a change of them is recorded as an
# update of the inbox. Left out: what the system keeps up to date by itself (template syncs,
# connection state, token expiry), secret settings (tokens, passwords, keys), and of provider_config,
# which holds credentials, everything but its on/off call settings. A change of only those is not
# recorded.
module Lexi::Channelable
  SYSTEM_ATTRIBUTES = %w[
    created_at updated_at
    message_templates message_templates_last_updated content_templates content_templates_last_updated
    provider_connection phone_number_health phone_number_health_checked_at phone_number_health_error
    expires_at refresh_token_expires_at
  ].freeze
  PROVIDER_CONFIG_SETTINGS = %w[calling_enabled recording_enabled].freeze

  def create_audit_log_entry
    super
    return if inbox.blank?

    changes = audited_channel_changes
    return if changes.empty?

    Lexi::AuditLog.create!(auditable: inbox, associated: account, action: 'update', audited_changes: changes)
  end

  private

  def audited_channel_changes
    changes = saved_changes.except(*SYSTEM_ATTRIBUTES).to_h
    provider_config_change = changes.delete('provider_config')&.map { |config| provider_config_settings(config) }
    changes['provider_config'] = provider_config_change if provider_config_change&.uniq&.many?
    Lexi::AuditLog.without_secrets(changes)
  end

  def provider_config_settings(config)
    config.to_h.stringify_keys.slice(*PROVIDER_CONFIG_SETTINGS).select { |_, value| [true, false].include?(value) }
  end
end
