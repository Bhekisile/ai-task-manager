class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy

  enum :status, {
    active: 0,
    archived: 1
  }

  validates :name, presence: true

  def completed_tasks_count
    tasks.completed.count
  end

  def total_tasks_count
    tasks.count
  end

  def completion_percentage
    return 0 if total_tasks_count.zero?

    (completed_tasks_count.to_f / total_tasks_count * 100).round
  end

  def completed?
    completion_percentage == 100
  end

  def archive_if_completed
    archived! if completed?
  end
end
