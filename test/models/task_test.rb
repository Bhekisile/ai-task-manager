require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "creates a task through its project and user" do
    user = create_test_user(email: "task-test@example.com")
    project = create_test_project(user: user)
    task = create_test_task(project: project)

    assert task.persisted?
    assert_equal project.id, task.project_id
    assert_equal user.id, task.project.user_id
  end
end
