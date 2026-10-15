require "test_helper"

class ActivityLogTest < ActiveSupport::TestCase
  test "creates an activity log for an existing task" do
    user = create_test_user(email: "activity-test@example.com")
    project = create_test_project(user: user)
    task = create_test_task(project: project)

    activity_log = ActivityLog.create!(
      task: task,
      action: "completed"
    )

    assert activity_log.persisted?
    assert_equal task.id, activity_log.task_id
    assert_equal task, activity_log.task
  end
end
