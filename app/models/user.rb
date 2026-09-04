class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many  :projects, dependent: :destroy
  has_many :tasks, through: :projects

  enum :role, {
    member: 0,
    admin: 1
  }

  # def completed_tasks_count
  #   tasks.completed.count
  #   # @completed_tasks_count ||= tasks.completed.count
  # end

  # def total_tasks_count
  #   tasks.count
  #   # @total_tasks_count ||= tasks.count
  # end

  # def remaining_tasks_count
  #   total_tasks_count - completed_tasks_count
  # end

  # def completion_percentage
  #   return 0 if total_tasks_count.zero?

  #   (completed_tasks_count.to_f / total_tasks_count * 100).round
  # end

  def recent_tasks
    tasks.order(created_at: :desc).limit(5)
  end

  def task_statistics
    total = tasks.count
    completed = tasks.completed.count
    {
      total: total,
      completed: completed,
      remaining: total - completed,
      percentage: total.zero? ? 0 : (completed.to_f / total * 100).round
    }
  end
end
