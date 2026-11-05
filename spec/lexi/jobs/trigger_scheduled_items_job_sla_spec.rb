require 'rails_helper'

RSpec.describe TriggerScheduledItemsJob do
  it 'queues the SLA checks with the other scheduled items' do
    expect { described_class.perform_now }.to have_enqueued_job(Sla::TriggerSlasForAccountsJob)
  end
end
