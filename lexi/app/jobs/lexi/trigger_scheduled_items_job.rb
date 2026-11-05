# SLA checks run with the other five-minute scheduled items.
module Lexi::TriggerScheduledItemsJob
  def perform
    super
    Sla::TriggerSlasForAccountsJob.perform_later
  end
end
