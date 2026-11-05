class Api::V1::Accounts::CustomRolesController < Api::V1::Accounts::BaseController
  before_action :fetch_custom_role, only: %i[show update destroy]
  before_action :check_authorization

  def index
    @custom_roles = Current.account.custom_roles.order(:created_at)
  end

  def show; end

  def create
    @custom_role = Current.account.custom_roles.create!(custom_role_params)
  end

  def update
    @custom_role.update!(custom_role_params)
  end

  def destroy
    @custom_role.destroy!
    head :ok
  end

  private

  def fetch_custom_role
    @custom_role = Current.account.custom_roles.find(params[:id])
  end

  def custom_role_params
    params.require(:custom_role).permit(:name, :description, permissions: [])
  end
end
