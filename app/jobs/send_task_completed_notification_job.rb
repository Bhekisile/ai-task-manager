class SendTaskCompletedNotificationJob < ApplicationJob
  queue_as :default

  retry_on RuntimeError, wait: 5.seconds, attempts: 3

  def perform(task_id)
    task = Task.find(task_id)

    notification_type = "task_completed"

    return if NotificationDelivery.sent_for?(task, notification_type)

    # if NotificationDelivery.sent_for?(task, notification_type)
    #   Rails.logger.info "📧 NOTIFICATION SENT for Task ##{task.id}"
    #   return
    # end

    # Simulate application failure AFTER notification was sent
    # raise "💥 Application crashed after notification was sent"
    idempotency_key = "task-#{task.id}-#{notification_type}"

    result = FakeNotificationProvider.send_notification(
      idempotency_key: idempotency_key
    )

    if [:sent, :already_processed].include?(result)
      NotificationDelivery.create!(
        task: task,
        notification_type: notification_type,
        sent_at: Time.current
      )
    end
  end
end
