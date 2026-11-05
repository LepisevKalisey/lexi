require 'rails_helper'

RSpec.describe Conversation do
  let(:account) { create(:account) }
  let(:sla_policy) { create(:sla_policy, account: account) }

  describe 'applying an SLA policy' do
    it 'applies the policy when the conversation gets one' do
      conversation = create(:conversation, account: account)

      conversation.update!(sla_policy: sla_policy)

      expect(conversation.applied_sla).to have_attributes(sla_policy_id: sla_policy.id, account_id: account.id, sla_status: 'active')
    end

    it 'applies the same policy only once' do
      conversation = create(:conversation, account: account, sla_policy: sla_policy)

      conversation.update!(sla_policy: nil)
      conversation.update!(sla_policy: sla_policy)

      expect(AppliedSla.where(conversation: conversation).count).to eq(1)
    end
  end

  describe '#sla_applicable?' do
    it 'is false for a blocked contact' do
      conversation = create(:conversation, account: account)
      conversation.contact.update!(blocked: true)

      expect(conversation.sla_applicable?).to be(false)
    end
  end
end
