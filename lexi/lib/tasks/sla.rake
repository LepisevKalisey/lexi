namespace :sla do
  desc 'Fill completed_at of hit and missed SLAs from conversation resolutions (dry run unless APPLY=true)'
  task backfill_completed_at: :environment do
    Sla::BackfillAppliedSlaCompletedAtService.new(
      account_id: ENV.fetch('ACCOUNT_ID', nil),
      all_accounts: ENV['ALL_ACCOUNTS'] == 'true',
      apply: ENV['APPLY'] == 'true',
      after_id: ENV.fetch('AFTER_ID', nil)
    ).perform
  end
end
