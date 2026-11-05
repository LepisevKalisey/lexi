require 'rails_helper'

RSpec.describe 'Audit records of API token requests', type: :request do
  let(:account) { create(:account) }
  let(:admin) { create(:user, account: account, role: :administrator) }
  let(:team) { create(:team, account: account) }

  it 'are attributed to the user who owns the access token' do
    patch "/api/v1/accounts/#{account.id}/teams/#{team.id}",
          params: { team: { name: 'renamed' } }, headers: { api_access_token: admin.access_token.token }, as: :json

    expect(response).to have_http_status(:success)
    expect(Lexi::AuditLog.where(auditable: team, action: 'update').last.user).to eq(admin)
  end
end
