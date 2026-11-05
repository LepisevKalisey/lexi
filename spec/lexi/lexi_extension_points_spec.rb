require 'rails_helper'

# Fails when an upstream sync renames or drops a class LEXI hooks into.
RSpec.describe Lexi do
  describe 'extension points' do
    [
      %w[DashboardController Lexi::DashboardController],
      %w[AccountDashboard Lexi::AccountDashboard],
      %w[Conversation Lexi::Concerns::Conversation],
      %w[Account Lexi::Concerns::Account],
      %w[AccountUser Lexi::AccountUser],
      %w[AccountUser Lexi::Concerns::AccountUser],
      %w[Conversations::EventDataPresenter Lexi::Conversations::EventDataPresenter],
      %w[Conversations::PermissionFilterService Lexi::Conversations::PermissionFilterService],
      %w[ActionService Lexi::ActionService],
      %w[AutomationRule Lexi::AutomationRule],
      %w[TriggerScheduledItemsJob Lexi::TriggerScheduledItemsJob],
      %w[Api::V1::Accounts::AgentsController Lexi::Api::V1::Accounts::AgentsController],
      %w[ConversationPolicy Lexi::ConversationPolicy],
      %w[ContactPolicy Lexi::ContactPolicy],
      %w[ReportPolicy Lexi::ReportPolicy],
      %w[CsatSurveyResponsePolicy Lexi::CsatSurveyResponsePolicy],
      %w[ArticlePolicy Lexi::ArticlePolicy],
      %w[CategoryPolicy Lexi::CategoryPolicy],
      %w[PortalPolicy Lexi::PortalPolicy],
      %w[Account Lexi::Audit::Account],
      %w[AccountUser Lexi::Audit::AccountUser],
      %w[AutomationRule Lexi::Audit::AutomationRule],
      %w[Inbox Lexi::Audit::Inbox],
      %w[InboxMember Lexi::Audit::InboxMember],
      %w[Macro Lexi::Audit::Macro],
      %w[Team Lexi::Audit::Team],
      %w[TeamMember Lexi::Audit::TeamMember],
      %w[User Lexi::Audit::User],
      %w[Webhook Lexi::Audit::Webhook],
      %w[Channel::WebWidget Lexi::Channelable],
      %w[DeleteObjectJob Lexi::DeleteObjectJob],
      %w[DeviseOverrides::SessionsController Lexi::DeviseOverrides::SessionsController],
      %w[Api::V1::Accounts::Conversations::MessagesController Lexi::Api::V1::Accounts::Conversations::MessagesController]
    ].each do |core_class, lexi_module|
      it "adds #{lexi_module} to #{core_class}" do
        expect(core_class.constantize.ancestors).to include(lexi_module.constantize)
      end
    end

    it 'writes audit records as Lexi::AuditLog' do
      expect(Audited.audit_class).to eq(Lexi::AuditLog)
    end
  end
end
