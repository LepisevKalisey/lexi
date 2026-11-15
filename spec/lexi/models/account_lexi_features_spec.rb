require 'rails_helper'

# LEXI account features kept in accounts.settings (L-018).
RSpec.describe Account do
  let(:account) { create(:account) }

  describe 'internal_chat' do
    it 'is off for a new account' do
      expect(account.feature_enabled?('internal_chat')).to be(false)
      expect(account.all_features).to include('internal_chat' => false)
      expect(account.enabled_features).not_to have_key('internal_chat')
    end

    it 'switches like a core feature flag and stays out of the flag bits' do
      flags_before = account.slice(*Featurable::FEATURE_FLAG_COLUMNS)

      account.enable_features!('internal_chat')

      expect(account.reload.feature_enabled?('internal_chat')).to be(true)
      expect(account.enabled_features).to include('internal_chat' => true)
      expect(account.slice(*Featurable::FEATURE_FLAG_COLUMNS)).to eq(flags_before)

      account.disable_features!('internal_chat')
      expect(account.reload.feature_enabled?('internal_chat')).to be(false)
    end

    it 'follows the chosen list of selected_feature_flags' do
      account.update!(selected_feature_flags: %i[feature_internal_chat feature_sla])

      expect(account.reload.feature_enabled?('internal_chat')).to be(true)
      expect(account.feature_enabled?('sla')).to be(true)

      account.update!(selected_feature_flags: %i[feature_sla])

      expect(account.reload.feature_enabled?('internal_chat')).to be(false)
      expect(account.feature_enabled?('sla')).to be(true)
    end

    it 'keeps the other settings' do
      account.update!(auto_resolve_after: 60)
      account.enable_features!('internal_chat')

      expect(account.reload.auto_resolve_after).to eq(60)
    end
  end
end
