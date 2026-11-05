require 'rails_helper'

# Fails when an upstream sync renames or drops a class LEXI hooks into.
RSpec.describe Lexi do
  describe 'extension points' do
    {
      'DashboardController' => 'Lexi::DashboardController',
      'AccountDashboard' => 'Lexi::AccountDashboard',
      'Conversation' => 'Lexi::Concerns::Conversation',
      'Account' => 'Lexi::Concerns::Account',
      'AccountUser' => 'Lexi::AccountUser',
      'Conversations::EventDataPresenter' => 'Lexi::Conversations::EventDataPresenter',
      'Conversations::PermissionFilterService' => 'Lexi::Conversations::PermissionFilterService',
      'ActionService' => 'Lexi::ActionService',
      'AutomationRule' => 'Lexi::AutomationRule',
      'TriggerScheduledItemsJob' => 'Lexi::TriggerScheduledItemsJob',
      'Api::V1::Accounts::AgentsController' => 'Lexi::Api::V1::Accounts::AgentsController',
      'ConversationPolicy' => 'Lexi::ConversationPolicy',
      'ContactPolicy' => 'Lexi::ContactPolicy',
      'ReportPolicy' => 'Lexi::ReportPolicy',
      'CsatSurveyResponsePolicy' => 'Lexi::CsatSurveyResponsePolicy',
      'ArticlePolicy' => 'Lexi::ArticlePolicy',
      'CategoryPolicy' => 'Lexi::CategoryPolicy',
      'PortalPolicy' => 'Lexi::PortalPolicy'
    }.each do |core_class, lexi_module|
      it "adds #{lexi_module} to #{core_class}" do
        expect(core_class.constantize.ancestors).to include(lexi_module.constantize)
      end
    end

    it 'adds Lexi::Concerns::AccountUser to AccountUser' do
      expect(AccountUser.ancestors).to include(Lexi::Concerns::AccountUser)
    end
  end
end
