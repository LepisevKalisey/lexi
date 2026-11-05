# SLA report: conversations that missed a target (index, download) and totals (metrics).
# Filters come from the dashboard: since/until (epoch), assigned_agent_id, inbox_id, team_id,
# sla_policy_id and label_list.
class Api::V1::Accounts::AppliedSlasController < Api::V1::Accounts::BaseController
  RESULTS_PER_PAGE = 25

  before_action :check_sla_feature
  before_action :check_authorization
  before_action :set_applied_slas

  def index
    breached = @applied_slas.breached
    @count = breached.count
    @current_page = [params[:page].to_i, 1].max
    @applied_slas = breached.includes(:sla_policy, :sla_events, conversation: %i[contact assignee])
                            .order(created_at: :desc)
                            .page(@current_page).per(RESULTS_PER_PAGE)
  end

  def metrics
    total = @applied_slas.count
    misses = @applied_slas.breached.count
    render json: { total_applied_slas: total, number_of_sla_misses: misses, hit_rate: hit_rate(total, misses) }
  end

  def download
    @applied_slas = @applied_slas.breached.includes(:sla_policy, :sla_events, conversation: %i[contact assignee]).order(created_at: :desc)
    response.headers['Content-Type'] = 'text/csv'
    response.headers['Content-Disposition'] = 'attachment; filename=breached_conversation.csv'
    render layout: false, template: 'api/v1/accounts/applied_slas/download', formats: [:csv]
  end

  private

  def check_sla_feature
    raise Pundit::NotAuthorizedError unless Current.account.feature_enabled?('sla')
  end

  def set_applied_slas
    scope = Current.account.applied_slas.with_sla_applicable_conversation
    scope = scope.where(applied_slas: { created_at: date_range }) if date_range
    scope = scope.where(sla_policy_id: params[:sla_policy_id]) if params[:sla_policy_id].present?
    @applied_slas = filter_by_conversation(scope)
  end

  def filter_by_conversation(scope)
    { assigned_agent_id: :assignee_id, inbox_id: :inbox_id, team_id: :team_id }.each do |param, column|
      scope = scope.where(conversations: { column => params[param] }) if params[param].present?
    end
    return scope if params[:label_list].blank?

    scope.where(conversation_id: Current.account.conversations.tagged_with(params[:label_list]).select(:id))
  end

  def date_range
    return if params[:since].blank? || params[:until].blank?

    Time.zone.at(params[:since].to_i)..Time.zone.at(params[:until].to_i)
  end

  def hit_rate(total, misses)
    return '100%' if misses.zero?

    "#{((total - misses) * 100.0 / total).round(2)}%"
  end
end
