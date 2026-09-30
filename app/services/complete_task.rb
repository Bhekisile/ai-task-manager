class CompleteTask
  def self.call(task)
    new(task).call
  end

  def initialize(task)
    @task = task
  end

  def call
    return false if @task.done?

    ActiveRecord::Base.transaction do
      @task.done!

      ActivityLog.create!(
        task: @task,
        action: "completed"
      )
    end

    SendTaskCompletedNotificationJob.perform_later(@task.id)

    true
  end
end
