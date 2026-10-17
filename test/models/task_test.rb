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

  test "is invalid without a title" do
    user = create_test_user(email: "blank-title@example.com")
    project = create_test_project(user: user)

    task = Task.new(
      title: "",
      priority: :medium,
      status: :todo,
      project: project
    )

    assert_not task.valid?
    assert_includes task.errors[:title], "can't be blank"
  end

  test "is valid with a title, priority, status, and project" do
    user = create_test_user(email: "valid-task@example.com")
    project = create_test_project(user: user)

    task = Task.new(
      title: "Write model tests",
      priority: :medium,
      status: :todo,
      project: project
    )

    assert task.valid?, task.errors.full_messages.to_sentence
  end

  test "rejects an undefined priority" do
    assert_raises(ArgumentError) do
      Task.new(priority: :urgent)
    end
  end

  test "accepts a valid status" do
    task = Task.new(status: :in_progress)

    assert_equal "in_progress", task.status
  end

  test "persists its status in the database" do
    user = create_test_user(email: "status-test@example.com")
    project = create_test_project(user: user)

    task = create_test_task(project: project)
    task.update!(status: :in_progress)

    saved_task = Task.find(task.id)

    assert_equal "in_progress", saved_task.status
  end

  test "completed scope returns only completed tasks" do
    user = create_test_user(email: "scope-test@example.com")
    project = create_test_project(user: user)

    completed_task = create_test_task(
      project: project,
      title: "Completed task"
    )
    completed_task.update!(status: :done)

    create_test_task(
      project: project,
      title: "Incomplete task"
    )

    assert_equal [completed_task], Task.completed.to_a
  end

  test "completed scope counts only completed tasks" do
    user = create_test_user(email: "count-scope@example.com")
    project = create_test_project(user: user)

    first_task = create_test_task(
      project: project,
      title: "First completed task"
    )
    first_task.update!(status: :done)

    second_task = create_test_task(
      project: project,
      title: "Second completed task"
    )
    second_task.update!(status: :done)

    create_test_task(
      project: project,
      title: "Incomplete task"
    )

    assert_equal 2, Task.completed.count
  end

  test "is destroyed when its project is destroyed" do
    user = create_test_user(email: "dependent-test@example.com")
    project = create_test_project(user: user)
    task = create_test_task(project: project)

    task_id = task.id

    project.destroy!

    assert_raises(ActiveRecord::RecordNotFound) do
      Task.find(task_id)
    end
  end

  test "belongs to its project" do
    user = create_test_user(email: "belongs-to-test@example.com")
    project = create_test_project(user: user)
    task = create_test_task(project: project)

    assert_equal project, task.project
  end

  test "is invalid without a project" do
    task = Task.new(
      title: "Orphan task",
      priority: :medium,
      status: :todo
    )

    assert_not task.valid?
    assert_includes task.errors[:project], "must exist"
  end

  test "database rejects a task with a nonexistent project" do
    assert_raises(ActiveRecord::InvalidForeignKey) do
      Task.insert_all!([
        {
          title: "Invalid task",
          priority: 1,
          status: 0,
          project_id: -1,
          lock_version: 0,
          created_at: Time.current,
          updated_at: Time.current
        }
      ])
    end
  end
end
