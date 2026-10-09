class CompleteTask
  def self.call(task)
    new(task).call
  end

  def initialize(task)
    @task = task
  end

  def call
    completed = false

    ActiveRecord::Base.transaction do
      @task.lock!

      if @task.todo?
        @task.update!(status: :done)

        ActivityLog.create!(
          task: @task,
          action: "completed"
        )

        completed = true
      end
    end

    if completed
      SendTaskCompletedNotificationJob.perform_later(@task.id)
    end

    completed
  end
end
