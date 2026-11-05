# An SLA policy applied to one conversation, with the outcome so far. Stays active until the
# conversation is resolved, then becomes hit or missed.
class AppliedSla < ApplicationRecord
  belongs_to :account
  belongs_to :sla_policy
  belongs_to :conversation
  has_many :sla_events, dependent: :destroy

  enum sla_status: { active: 0, hit: 1, missed: 2, active_with_misses: 3 }

  BREACHED_STATUSES = %w[missed active_with_misses].freeze

  before_validation :ensure_account_id

  # Blocked contacts drop out of SLA tracking. A conversation whose contact row is already gone
  # (the contact's conversations are removed later, in a job) stays in.
  scope :with_sla_applicable_conversation, lambda {
    left_joins(conversation: :contact).where(contacts: { blocked: [false, nil] })
  }
  scope :breached, -> { where(sla_status: BREACHED_STATUSES) }

  def frt_due_at
    return if sla_policy.first_response_time_threshold.blank?

    calculate_due_at(conversation.created_at, sla_policy.first_response_time_threshold)
  end

  def nrt_due_at
    return if sla_policy.next_response_time_threshold.blank? || conversation.waiting_since.blank?

    calculate_due_at(conversation.waiting_since, sla_policy.next_response_time_threshold)
  end

  def rt_due_at
    return if sla_policy.resolution_time_threshold.blank?

    calculate_due_at(conversation.created_at, sla_policy.resolution_time_threshold)
  end

  def push_event_data
    {
      id: id,
      sla_id: sla_policy_id,
      sla_status: sla_status,
      created_at: created_at.to_i,
      updated_at: updated_at.to_i,
      sla_completed_at: completed_at&.to_i,
      sla_description: sla_policy.description,
      sla_name: sla_policy.name,
      sla_first_response_time_threshold: sla_policy.first_response_time_threshold,
      sla_next_response_time_threshold: sla_policy.next_response_time_threshold,
      sla_only_during_business_hours: sla_policy.only_during_business_hours,
      sla_resolution_time_threshold: sla_policy.resolution_time_threshold,
      sla_frt_due_at: frt_due_at,
      sla_nrt_due_at: nrt_due_at,
      sla_rt_due_at: rt_due_at
    }
  end

  private

  def calculate_due_at(start_time, threshold_seconds)
    return (start_time + threshold_seconds.seconds).to_i unless sla_policy.only_during_business_hours

    Sla::BusinessHoursService.new(
      inbox: conversation.inbox,
      start_time: start_time,
      threshold_seconds: threshold_seconds,
      working_hours_by_day: working_hours_by_day
    ).deadline.to_i
  end

  # One read of the inbox's working hours serves all three deadlines.
  def working_hours_by_day
    @working_hours_by_day ||= conversation.inbox.working_hours.index_by(&:day_of_week)
  end

  def ensure_account_id
    self.account_id ||= conversation&.account_id
  end
end
