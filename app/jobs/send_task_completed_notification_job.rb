class SendTaskCompletedNotificationJob < ApplicationJob
  queue_as :default

  retry_on RuntimeError, wait: 5.seconds, attempts: 3

  def perform(task_id)
    task = Task.find(task_id)

    if executions == 1
      raise "Notification service is unavailable"
    end

    Rails.logger.info "✅ Notification sent for Task ##{task.id}"
  end
end
