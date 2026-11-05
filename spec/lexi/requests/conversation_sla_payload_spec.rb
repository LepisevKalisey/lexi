require 'rails_helper'

RSpec.describe 'LEXI SLA fields of a conversation', type: :request do
  let(:account) { create(:account) }
  let(:admin) { create(:user, account: account, role: :administrator) }
  let(:sla_policy) { create(:sla_policy, account: account, first_response_time_threshold: 1.hour) }
  let(:conversation) { create(:conversation, account: account, sla_policy: sla_policy, created_at: 2.hours.ago) }

  before do
    Sla::EvaluateAppliedSlaService.new(applied_sla: conversation.applied_sla).perform
  end

  it 'shows the applied SLA and its missed targets when the sla feature is on' do
    account.enable_features!('sla')

    get "/api/v1/accounts/#{account.id}/conversations/#{conversation.display_id}", headers: admin.create_new_auth_token, as: :json

    expect(response).to have_http_status(:success)
    expect(response.parsed_body['applied_sla']).to include('sla_id' => sla_policy.id, 'sla_status' => 'active_with_misses')
    expect(response.parsed_body['sla_events'].pluck('event_type')).to eq(['frt'])
  end

  it 'leaves the SLA fields out when the sla feature is off' do
    account.disable_features!('sla')

    get "/api/v1/accounts/#{account.id}/conversations/#{conversation.display_id}", headers: admin.create_new_auth_token, as: :json

    expect(response.parsed_body).not_to have_key('applied_sla')
  end

  it 'adds the same fields to conversation events' do
    account.enable_features!('sla')

    push_data = Conversations::EventDataPresenter.new(conversation.reload).push_data

    expect(push_data[:applied_sla]).to include(sla_id: sla_policy.id)
    expect(push_data[:sla_events].pluck(:event_type)).to eq(['frt'])
  end
end
