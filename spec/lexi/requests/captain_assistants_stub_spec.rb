require 'rails_helper'

RSpec.describe 'LEXI Captain assistants stub', type: :request do
  let(:account) { create(:account) }
  let(:agent) { create(:user, account: account, role: :agent) }

  it 'answers the dashboard with an empty assistant list' do
    get "/api/v1/accounts/#{account.id}/captain/assistants", headers: agent.create_new_auth_token, as: :json

    expect(response).to have_http_status(:success)
    expect(response.parsed_body).to eq('payload' => [], 'meta' => { 'total_count' => 0, 'page' => 1 })
  end

  it 'still requires a signed-in user of the account' do
    get "/api/v1/accounts/#{account.id}/captain/assistants", as: :json

    expect(response).to have_http_status(:unauthorized)
  end
end
