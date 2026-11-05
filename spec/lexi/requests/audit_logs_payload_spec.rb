require 'rails_helper'

RSpec.describe 'Audit log payload', type: :request do
  let(:account) { create(:account) }
  let(:admin) { create(:user, account: account, role: :administrator) }

  before { account.enable_features!(:audit_logs) }

  def audit_logs
    get "/api/v1/accounts/#{account.id}/audit_logs", headers: admin.create_new_auth_token, as: :json
    response.parsed_body['audit_logs']
  end

  it 'returns of the audited record only the ids the screen reads' do
    agent = create(:user, account: account)
    account_user = account.account_users.find_by!(user: agent)

    entry = audit_logs.find { |log| log['auditable_type'] == 'AccountUser' && log['auditable_id'] == account_user.id }
    expect(entry['auditable']).to eq('id' => account_user.id, 'user_id' => agent.id)
    expect(entry['created_at']).to be_a(Integer)
  end

  it 'returns no audited record once the record is deleted' do
    team = create(:team, account: account)
    team.destroy!

    entries = audit_logs.select { |log| log['auditable_type'] == 'Team' }
    expect(entries.pluck('action')).to contain_exactly('create', 'destroy')
    expect(entries.pluck('auditable')).to all(be_nil)
  end
end
