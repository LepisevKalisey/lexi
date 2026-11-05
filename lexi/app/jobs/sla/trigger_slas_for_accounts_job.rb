# Runs every five minutes (TriggerScheduledItemsJob): queues an SLA check for each account that
# has SLA policies and the sla feature on.
class Sla::TriggerSlasForAccountsJob < ApplicationJob
  queue_as :scheduled_jobs

  def perform
    Account.where(id: SlaPolicy.select(:account_id)).find_each do |account|
      Sla::ProcessAccountAppliedSlasJob.perform_later(account) if account.feature_enabled?('sla')
    end
  end
end
