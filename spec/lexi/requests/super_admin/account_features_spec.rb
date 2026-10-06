require 'rails_helper'

RSpec.describe 'LEXI super admin account features', type: :request do
  let(:super_admin) { create(:super_admin) }
  let(:account) { create(:account) }

  before { sign_in(super_admin, scope: :super_admin) }

  it 'shows a checkbox for every regular and premium feature' do
    get "/super_admin/accounts/#{account.id}/edit"

    expect(response).to have_http_status(:success)
    expect(response.body).to include('id="lexi_feature_sla"')
    expect(response.body).to include('id="lexi_feature_custom_roles"')
    expect(response.body).to include('id="lexi_feature_audit_logs"')
  end

  it 'carries enabled internal features the form does not show' do
    account.enable_features!('search_with_gin')

    get "/super_admin/accounts/#{account.id}/edit"

    expect(response.body).not_to include('id="lexi_feature_search_with_gin"')
    expect(response.body).to include('name="enabled_features[feature_search_with_gin]"')
  end

  it 'replaces the account features with the checked ones' do
    account.enable_features!('inbound_emails')

    patch "/super_admin/accounts/#{account.id}",
          params: { account: { name: account.name }, enabled_features: { feature_sla: '1', feature_custom_roles: '1' } }

    account.reload
    expect(account.feature_enabled?('sla')).to be(true)
    expect(account.feature_enabled?('custom_roles')).to be(true)
    expect(account.feature_enabled?('inbound_emails')).to be(false)
  end
end
