class SendTaskCompletedNotificationJob < ApplicationJob
  queue_as :default

  retry_on RuntimeError, wait: 5.seconds, attempts: 3

  # def perform(task_id)
  #   task = Task.find(task_id)

  #   if executions == 1
  #     raise "Notification service is unavailable"
  #   end

  #   Rails.logger.info "✅ Notification sent for Task ##{task.id}"
  # end

  def perform(task_id)
    task = Task.find(task_id)

    already_sent = NotificationDelivery.where(
      task: task,
      notification_type: "task_completed"
    ).where.not(sent_at: nil).exists?

    if already_sent
      Rails.logger.info "⏭️ Notification already sent for Task ##{task.id}"
      return
    end

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
