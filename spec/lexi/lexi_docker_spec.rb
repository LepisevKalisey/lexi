require 'rails_helper'

# The LEXI image is built from lexi/docker/Dockerfile: fazer.ai's docker/Dockerfile without the
# steps that download Chatwoot Enterprise (L-017). Fails when an upstream sync changes the
# original: port the change to lexi/docker/Dockerfile, then pin the new SHA256 in
# lexi/docker/upstream.json.
RSpec.describe Lexi do
  describe 'Docker image' do
    let(:dockerfile) { Rails.root.join('lexi/docker/Dockerfile').read }

    JSON.parse(Rails.root.join('lexi/docker/upstream.json').read).each do |original, sha256|
      it "follows #{original} as reviewed" do
        expect(Digest::SHA256.file(Rails.root.join(original)).hexdigest).to eq(sha256)
      end
    end

    it 'neither downloads nor links enterprise/' do
      %w[enterprise-lock .enterprise_lock cw-enterprise official-enterprise enterprise.sh].each do |marker|
        expect(dockerfile).not_to include(marker)
      end
    end

    it 'is the Dockerfile the release workflow builds, from a tree without enterprise/' do
      workflow = Rails.root.join('.github/workflows/lexi-release.yml').read

      expect(workflow).to include('file: lexi/docker/Dockerfile')
      expect(workflow).to include('rm -rf enterprise spec/enterprise')
    end
  end
end
