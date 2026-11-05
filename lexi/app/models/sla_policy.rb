# Thresholds a conversation must meet: first response, next response and resolution, in
# seconds, optionally counted only during the inbox's business hours.
class SlaPolicy < ApplicationRecord
  belongs_to :account
  has_many :conversations, dependent: :nullify
  has_many :applied_slas, dependent: :destroy

  validates :name, presence: true

  def push_event_data
    {
      id: id,
      name: name,
      description: description,
      first_response_time_threshold: first_response_time_threshold,
      next_response_time_threshold: next_response_time_threshold,
      resolution_time_threshold: resolution_time_threshold,
      only_during_business_hours: only_during_business_hours
    }
  end
end
