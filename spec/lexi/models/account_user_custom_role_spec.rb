require 'rails_helper'

RSpec.describe AccountUser do
  let(:account) { create(:account) }
  let(:custom_role) { create(:custom_role, account: account, permissions: %w[conversation_unassigned_manage report_manage]) }

  describe '#permissions' do
    it 'gives an agent with a custom role the role permissions instead of the agent role' do
      account_user = create(:account_user, account: account, role: :agent, custom_role: custom_role)

      expect(account_user.permissions).to eq(%w[custom_role conversation_unassigned_manage report_manage])
    end

    it 'keeps the administrator permissions for an administrator with a custom role' do
      account_user = create(:account_user, account: account, role: :administrator, custom_role: custom_role)

      expect(account_user.permissions).to eq(['administrator'])
    end
  end

  it 'refuses a custom role of another account' do
    account_user = build(:account_user, account: account, custom_role: create(:custom_role))

    expect(account_user).not_to be_valid
  end
end
