class NotificationDelivery < ApplicationRecord
  belongs_to :task

  def self.sent_for?(task, notification_type)
    where(
      task: task,
      notification_type: notification_type
    ).where.not(sent_at: nil).exists?
  end
end
