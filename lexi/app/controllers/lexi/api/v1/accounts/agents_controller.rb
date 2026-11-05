# Agents can be given a custom role (custom_role_id) when they are invited or edited.
module Lexi::Api::V1::Accounts::AgentsController
  def create
    super
    return if @agent.nil? || params.dig(:agent, :custom_role_id).blank?

    Current.account.account_users.find_by!(user: @agent).update!(custom_role_id: params[:agent][:custom_role_id])
  end

  private

  def account_user_attributes
    [*super, :custom_role_id]
  end

  def allowed_agent_params
    [*super, :custom_role_id]
  end
end
