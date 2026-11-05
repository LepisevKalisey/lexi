require 'rails_helper'

RSpec.describe ActionService do
  let(:account) { create(:account) }
  let(:sla_policy) { create(:sla_policy, account: account) }
  let(:conversation) { create(:conversation, account: account) }

  describe '#add_sla' do
    it 'applies the SLA policy to the conversation' do
      described_class.new(conversation).add_sla([sla_policy.id])

      expect(conversation.reload.sla_policy).to eq(sla_policy)
      expect(conversation.applied_sla.sla_policy).to eq(sla_policy)
    end

    it 'keeps the policy a conversation already runs under' do
      other_policy = create(:sla_policy, account: account)
      conversation.update!(sla_policy: other_policy)

      described_class.new(conversation).add_sla([sla_policy.id])

      expect(conversation.reload.sla_policy).to eq(other_policy)
    end

    it 'ignores a policy of another account' do
      foreign_policy = create(:sla_policy)

      described_class.new(conversation).add_sla([foreign_policy.id])

      expect(conversation.reload.sla_policy).to be_nil
    end
  end
end
