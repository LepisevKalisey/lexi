require 'rails_helper'

# LEXI replaces a few frontend modules of the base at build time (lexi/vite/overrides.ts).
# Fails when an upstream sync changes an original: check the LEXI replacement against
# the new original, then pin the new SHA256 in lexi/vite/overrides.json.
RSpec.describe Lexi do
  describe 'frontend overrides' do
    JSON.parse(Rails.root.join('lexi/vite/overrides.json').read).each do |original, sha256|
      it "replaces #{original} as reviewed" do
        expect(Digest::SHA256.file(Rails.root.join(original)).hexdigest).to eq(sha256)
        expect(Rails.root.join('lexi', original)).to exist
      end
    end

    it 'builds the frontend with the override plugin' do
      expect(Rails.root.join('vite.config.ts').read).to include('lexiOverrides()')
    end

    it 'hides the internal chat poll button while polls are off' do
      channel_view = Rails.root.join('app/javascript/dashboard/routes/dashboard/internalChat/ChannelView.vue')

      expect(channel_view.read).to include(':show-poll="pollsEnabled"')
    end
  end
end
