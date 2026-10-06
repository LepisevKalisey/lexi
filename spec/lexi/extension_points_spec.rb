require 'rails_helper'

# Fails when an upstream sync renames or drops a class LEXI hooks into.
RSpec.describe Lexi do
  describe 'extension points' do
    {
      'DashboardController' => 'Lexi::DashboardController',
      'AccountDashboard' => 'Lexi::AccountDashboard'
    }.each do |core_class, lexi_module|
      it "prepends #{lexi_module} to #{core_class}" do
        expect(core_class.constantize.ancestors).to include(lexi_module.constantize)
      end
    end
  end
end
