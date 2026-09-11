class Task < ApplicationRecord
  belongs_to :project, counter_cache: true

  enum :priority, {
    low: 0,
    medium: 1,
    high: 2
  }

  enum :status, {
    todo: 0,
    in_progress: 1,
    done: 2
  }

  validates :title, presence: true
  validates :priority, presence: true
  validates :status, presence: true

  scope :completed, -> { where(status: :done) }
  scope :pending, -> { where(status: :todo) }
  scope :high_priority, -> { where(priority: :high) }
end
