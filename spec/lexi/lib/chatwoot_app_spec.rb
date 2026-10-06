require 'rails_helper'

RSpec.describe ChatwootApp do
  describe '.extensions' do
    it 'loads lexi on a build without enterprise' do
      allow(described_class).to receive_messages(enterprise?: false, custom?: false)

      expect(described_class.extensions).to eq(%w[lexi])
    end

    it 'loads lexi after enterprise and before custom' do
      allow(described_class).to receive_messages(enterprise?: true, custom?: true)

      expect(described_class.extensions).to eq(%w[enterprise lexi custom])
    end
  end
end
