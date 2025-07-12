class User < ApplicationRecord
  has_many :duty_assignments, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :slack_id, presence: true, uniqueness: true

  def on_vacation?
    return false if vacation_start_date.blank? || vacation_end_date.blank?
    Date.current.between?(vacation_start_date, vacation_end_date)
  end

  def available_for_duty?
    !on_vacation?
  end

  def full_name
    name
  end

  def last_duty_assignment
    duty_assignments.recent.first
  end

  def total_duty_count
    duty_assignments.completed.count
  end
end
