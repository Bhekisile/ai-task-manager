class SendTaskCompletedNotificationJob < ApplicationJob
  queue_as :default

  retry_on RuntimeError, wait: 5.seconds, attempts: 3

  def perform(task_id)
    task = Task.find(task_id)

    return if NotificationDelivery.sent_for?(task, "task_completed")

    # Simulate sending the notification
    Rails.logger.info "📧 NOTIFICATION SENT for Task ##{task.id}"

    # Simulate application failure AFTER notification was sent
    # raise "💥 Application crashed after notification was sent"
    NotificationDelivery.create!(
      task: task,
      notification_type: "task_completed",
      sent_at: Time.current
    )
  end
end
