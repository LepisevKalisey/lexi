# The account's audit log for administrators, newest first, 25 records a page. It can be narrowed
# to record types (types[]), to a user by name or email (q), to a period in Unix time (since,
# until) and sorted oldest first (sort=asc); values of the wrong shape are ignored. An account
# without the audit_logs feature gets an empty page.
class Api::V1::Accounts::AuditLogsController < Api::V1::Accounts::BaseController
  PER_PAGE = 25
  # Seconds from 1970 to the end of year 9999: the times a Postgres timestamp holds.
  EPOCH_RANGE = (0..253_402_300_799)

  before_action :check_admin_authorization?

  def show
    return render json: empty_page unless Current.account.feature_enabled?('audit_logs')

    @audit_logs = audit_logs.includes(:auditable).page(params[:page]).per(PER_PAGE)
    @full_ip_addresses = Current.account.feature_enabled?('audit_log_ip_address')
  end

  private

  def empty_page
    { audit_logs: [], current_page: 1, per_page: PER_PAGE, total_entries: 0 }
  end

  def audit_logs
    scope = Current.account.associated_audits
    scope = scope.where(auditable_type: types) if types.present?
    scope = scope.where(created_at: time_param(:since)..) if time_param(:since)
    scope = scope.where(created_at: ..time_param(:until)) if time_param(:until)
    scope = search(scope) if search_term.present?
    scope.reorder(created_at: sort_direction, id: sort_direction)
  end

  def search(scope)
    term = "%#{ActiveRecord::Base.sanitize_sql_like(search_term)}%"
    scope.joins("LEFT JOIN users ON users.id = audits.user_id AND audits.user_type = 'User'")
         .where('users.name ILIKE :term OR users.display_name ILIKE :term OR users.email ILIKE :term ' \
                'OR audits.username ILIKE :term', term: term)
  end

  def types
    params[:types].grep(String) if params[:types].is_a?(Array)
  end

  def search_term
    params[:q].strip if params[:q].is_a?(String)
  end

  def time_param(key)
    value = params[key].to_s
    return unless value.match?(/\A\d+\z/) && EPOCH_RANGE.cover?(value.to_i)

    Time.zone.at(value.to_i)
  end

  def sort_direction
    params[:sort] == 'asc' ? :asc : :desc
  end
end
