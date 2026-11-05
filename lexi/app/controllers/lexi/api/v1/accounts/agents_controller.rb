# Agents can be given a custom role (custom_role_id) when they are invited or edited, and lose
# it with custom_role_id: null. The core update drops nil values (.compact), so removal is
# applied here.
module Lexi::Api::V1::Accounts::AgentsController
  def create
    super
    return if @agent.nil? || params.dig(:agent, :custom_role_id).blank?

    Current.account.account_users.find_by!(user: @agent).update!(custom_role_id: params[:agent][:custom_role_id])
  end

  def update
    super
    return unless params[:agent]&.key?(:custom_role_id) && params[:agent][:custom_role_id].blank?

    @agent.current_account_user.update!(custom_role_id: nil)
  end

  private

  def account_user_attributes
    [*super, :custom_role_id]
  end

  def allowed_agent_params
    [*super, :custom_role_id]
  end
end
