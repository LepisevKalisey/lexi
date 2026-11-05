require 'rails_helper'

RSpec.describe 'LEXI custom roles of agents', type: :request do
  let(:account) { create(:account) }
  let(:admin) { create(:user, account: account, role: :administrator) }
  let(:agent) { create(:user, account: account, role: :agent) }
  let(:custom_role) { create(:custom_role, account: account, permissions: ['conversation_manage']) }

  it 'gives an invited agent a custom role' do
    post "/api/v1/accounts/#{account.id}/agents",
         params: { agent: { name: 'Branch admin', email: 'branch.admin@example.com', role: 'agent', custom_role_id: custom_role.id } },
         headers: admin.create_new_auth_token, as: :json

    expect(response).to have_http_status(:success)
    expect(account.account_users.joins(:user).find_by(users: { email: 'branch.admin@example.com' }).custom_role).to eq(custom_role)
  end

  it 'changes and removes the custom role of an agent and shows it in the agent list' do
    patch "/api/v1/accounts/#{account.id}/agents/#{agent.id}",
          params: { agent: { custom_role_id: custom_role.id } }, headers: admin.create_new_auth_token, as: :json
    get "/api/v1/accounts/#{account.id}/agents", headers: admin.create_new_auth_token, as: :json

    expect(response.parsed_body.find { |row| row['id'] == agent.id }['custom_role_id']).to eq(custom_role.id)

    patch "/api/v1/accounts/#{account.id}/agents/#{agent.id}",
          params: { agent: { custom_role_id: nil } }, headers: admin.create_new_auth_token, as: :json

    expect(AccountUser.find_by(account: account, user: agent).custom_role_id).to be_nil
  end

  it 'tells the dashboard the role and its permissions in the profile' do
    AccountUser.find_by(account: account, user: agent).update!(custom_role: custom_role)

    get '/api/v1/profile', headers: agent.create_new_auth_token, as: :json

    account_payload = response.parsed_body['accounts'].find { |row| row['id'] == account.id }
    expect(account_payload).to include('custom_role_id' => custom_role.id, 'permissions' => %w[conversation_manage custom_role])
    expect(account_payload['custom_role']).to include('name' => custom_role.name)
  end
end
