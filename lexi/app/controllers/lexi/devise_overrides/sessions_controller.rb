# Sign-ins and sign-outs are recorded in the audit logs of the user's accounts. Sessions a super
# admin opens by impersonating the user are not: the user did not open them. A failure to record
# never stops the sign-in or sign-out.
module Lexi::DeviseOverrides::SessionsController
  def render_create_success
    record_session_event(@resource, 'sign_in') unless @impersonation
    super
  end

  def destroy
    impersonated = impersonated_session?
    super do |user|
      record_session_event(user, 'sign_out') unless impersonated
      yield user if block_given?
    end
  end

  private

  def impersonated_session?
    token_entry = @resource&.tokens&.dig(@token&.client)
    token_entry.is_a?(Hash) && token_entry.with_indifferent_access[:impersonation].present?
  end

  def record_session_event(user, action)
    return if user.blank?

    Lexi::AuditLogs::SessionEventService.new(user: user, action: action, remote_address: request.remote_ip,
                                             request_uuid: request.uuid).perform
  rescue StandardError => e
    ChatwootExceptionTracker.new(e, user: user).capture_exception
  end
end
