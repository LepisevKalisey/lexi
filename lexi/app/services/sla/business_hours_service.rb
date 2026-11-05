# Deadline for an SLA threshold counted only inside the inbox's working hours, in the inbox's
# time zone. Without working hours, or with every day closed, the deadline is wall-clock time.
class Sla::BusinessHoursService
  # A threshold longer than a decade of business time is a configuration error, not a deadline.
  MAX_DAYS = 3650

  def initialize(inbox:, start_time:, threshold_seconds:, working_hours_by_day: nil)
    @inbox = inbox
    @start_time = start_time
    @threshold_seconds = threshold_seconds.to_f
    @working_hours_by_day = working_hours_by_day
  end

  def deadline
    return @start_time + @threshold_seconds.seconds unless business_hours_apply?

    business_deadline
  end

  private

  def business_hours_apply?
    @inbox.working_hours_enabled? && working_hours_by_day.values.any? { |working_hour| !working_hour.closed_all_day? }
  end

  def business_deadline
    cursor = @start_time.in_time_zone(time_zone)
    remaining = @threshold_seconds

    MAX_DAYS.times do
      window = business_window(cursor.to_date)
      if window && cursor < window.last
        cursor = window.first if cursor < window.first
        available = window.last - cursor
        return cursor + remaining.seconds if remaining <= available

        remaining -= available
      end
      cursor = time_zone.local(cursor.year, cursor.month, cursor.day) + 1.day
    end

    raise ArgumentError, "SLA threshold #{@threshold_seconds}s exceeds #{MAX_DAYS} days of business time"
  end

  # [open, close) of a date in the inbox's time zone, or nil when the day is closed
  def business_window(date)
    working_hour = working_hours_by_day[date.wday]
    return if working_hour.nil? || working_hour.closed_all_day?

    day_start = time_zone.local(date.year, date.month, date.day)
    return [day_start, day_start + 1.day] if working_hour.open_all_day?

    [
      time_zone.local(date.year, date.month, date.day, working_hour.open_hour, working_hour.open_minutes),
      time_zone.local(date.year, date.month, date.day, working_hour.close_hour, working_hour.close_minutes)
    ]
  end

  def working_hours_by_day
    @working_hours_by_day ||= @inbox.working_hours.index_by(&:day_of_week)
  end

  def time_zone
    @time_zone ||= ActiveSupport::TimeZone[@inbox.timezone.presence || 'UTC'] || ActiveSupport::TimeZone['UTC']
  end
end
