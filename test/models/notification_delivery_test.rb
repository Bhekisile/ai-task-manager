require "test_helper"

class NotificationDeliveryTest < ActiveSupport::TestCase
  test "creates a notification delivery for an existing task" do
    user = create_test_user(email: "notification-test@example.com")
    project = create_test_project(user: user)
    task = create_test_task(project: project)

    delivery = NotificationDelivery.create!(
      task: task,
      notification_type: "email",
      sent_at: Time.current
    )

    assert delivery.persisted?
    assert_equal task.id, delivery.task_id
    assert_equal task, delivery.task
  end
end
