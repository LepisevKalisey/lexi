require 'rails_helper'

RSpec.describe DeleteObjectJob do
  include ActiveJob::TestHelper

  let(:account) { create(:account) }
  let(:admin) { create(:user, account: account, role: :administrator) }
  let(:inbox) { create(:inbox, account: account) }
  let!(:conversation) { create(:conversation, account: account, inbox: inbox, additional_attributes: { 'browser' => 'x' }) }

  it 'records a deleted conversation with the user and address, by its identifiers only' do
    described_class.perform_now(conversation, admin, '203.0.113.42')

    audit = Lexi::AuditLog.find_by!(auditable_type: 'Conversation', auditable_id: conversation.id, action: 'destroy')
    expect(audit).to have_attributes(user: admin, username: admin.email, remote_address: '203.0.113.42', associated: account)
    expect(audit.audited_changes).to include('display_id' => conversation.display_id, 'inbox_id' => inbox.id)
    expect(audit.audited_changes.keys).not_to include('additional_attributes', 'custom_attributes', 'uuid')
  end

  it 'does not record the conversations deleted along with an inbox one by one' do
    described_class.perform_now(inbox, admin, '203.0.113.42')

    expect(Lexi::AuditLog.where(auditable_type: 'Conversation').count).to eq(0)
    expect(Lexi::AuditLog.where(auditable_type: 'Inbox', action: 'destroy', user: admin).count).to eq(1)
  end
end
