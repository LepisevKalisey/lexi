# Fills completed_at for SLAs that were hit or missed before completed_at was recorded. The
# completion time is the conversation's latest resolution that falls inside the SLA's life
# (between its creation and the last status change). Dry run unless apply: true.
#
#   ACCOUNT_ID=1 bundle exec rake sla:backfill_completed_at          # dry run for one account
#   ALL_ACCOUNTS=true APPLY=true bundle exec rake sla:backfill_completed_at
class Sla::BackfillAppliedSlaCompletedAtService
  BATCH_SIZE = 500

  def initialize(account_id: nil, all_accounts: false, apply: false, after_id: nil, output: $stdout)
    @account_id = account_id
    @all_accounts = all_accounts
    @apply = apply
    @after_id = after_id.to_i
    @output = output
  end

  def perform
    raise ArgumentError, 'Provide exactly one of ACCOUNT_ID or ALL_ACCOUNTS=true' unless @account_id.present? ^ @all_accounts

    stats = { dry_run: !@apply, eligible: 0, matched: 0, updated: 0, skipped: 0, processed: 0, last_id: @after_id.nonzero? }
    eligible_scope.find_each(batch_size: BATCH_SIZE) { |applied_sla| process(applied_sla, stats) }
    @output.puts "SLA completed_at backfill: #{stats.except(:last_id).map { |key, value| "#{key}=#{value}" }.join(' ')}"
    stats
  end

  private

  def eligible_scope
    scope = AppliedSla.where(sla_status: %w[hit missed], completed_at: nil).where('applied_slas.id > ?', @after_id)
    @all_accounts ? scope : scope.where(account_id: @account_id)
  end

  def process(applied_sla, stats)
    stats[:eligible] += 1
    stats[:processed] += 1
    stats[:last_id] = applied_sla.id

    resolved_at = latest_resolution(applied_sla)
    if resolved_at.nil?
      stats[:skipped] += 1
      return
    end

    stats[:matched] += 1
    return unless @apply

    applied_sla.update_column(:completed_at, resolved_at) # rubocop:disable Rails/SkipsModelValidations
    stats[:updated] += 1
  end

  def latest_resolution(applied_sla)
    ReportingEvent.where(account_id: applied_sla.account_id, conversation_id: applied_sla.conversation_id, name: 'conversation_resolved')
                  .where(event_end_time: applied_sla.created_at..applied_sla.updated_at)
                  .maximum(:event_end_time)
  end
end
