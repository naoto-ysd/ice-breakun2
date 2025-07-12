class DutyAssignment < ApplicationRecord
  belongs_to :user

  validates :assignment_date, presence: true
  validates :assignment_method, presence: true, inclusion: { in: %w[random sequential custom] }
  validates :status, presence: true, inclusion: { in: %w[pending completed cancelled] }

  scope :pending, -> { where(status: "pending") }
  scope :completed, -> { where(status: "completed") }
  scope :for_date, ->(date) { where(assignment_date: date) }
  scope :recent, -> { order(assignment_date: :desc) }

  def mark_as_completed!
    update!(status: "completed", completed_at: Time.current)
  end

  def mark_as_cancelled!
    update!(status: "cancelled")
  end

  def pending?
    status == "pending"
  end

  def completed?
    status == "completed"
  end

  def cancelled?
    status == "cancelled"
  end

  def overdue?
    pending? && assignment_date < Date.current
  end
end
