require 'rails_helper'

# What LEXI leaves out of the audit log beyond the upstream specs: noise and secrets.
RSpec.describe Lexi::AuditLog do
  let(:account) { create(:account) }

  def updates_of(auditable_type)
    described_class.where(auditable_type: auditable_type, action: 'update')
  end

  it 'does not record activity pings or custom role changes of an agent' do
    account_user = create(:account_user, account: account)
    account_user.update!(active_at: Time.current)
    account_user.update!(custom_role: create(:custom_role, account: account))

    expect(updates_of('AccountUser').count).to eq(0)
  end

  it 'does not store a webhook secret' do
    create(:webhook, account: account, secret: 'webhook-secret')

    expect(described_class.where(auditable_type: 'Webhook').pluck(:audited_changes).to_json).not_to include('webhook-secret')
  end

  it 'does not record template syncs of a channel' do
    channel = create(:channel_twilio_sms, account: account)

    expect do
      channel.update!(content_templates: { 'templates' => [] }, content_templates_last_updated: Time.current)
    end.not_to change(updates_of('Inbox'), :count)
  end

  it 'masks secret keys inside a recorded JSON value' do
    channel = create(:channel_api, account: account)
    channel.update!(additional_attributes: { 'agent_reply_time_window' => 5, 'access_token' => 'nested-secret' })

    changes = updates_of('Inbox').last.audited_changes
    expect(changes['additional_attributes'].last).to include('agent_reply_time_window' => 5)
    expect(changes.to_json).not_to include('nested-secret')
  end
end
