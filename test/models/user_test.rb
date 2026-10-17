require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "returns zero statistics when the user has no tasks" do
    user = User.create!(
      email: "statistics-test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    assert_equal(
      {
        total: 0,
        completed: 0,
        remaining: 0,
        percentage: 0
      },
      user.task_statistics
    )
  end

  test "returns correct statistics when user has completed and incomplete tasks" do
    user = create_test_user(email: "mixed-statistics@example.com")
    project = create_test_project(user: user)

    completed_task = create_test_task(
      project: project,
      title: "Completed task"
    )
    completed_task.update!(status: :done)

    create_test_task(project: project, title: "Second task")
    create_test_task(project: project, title: "Third task")

    assert_equal(
      {
        total: 3,
        completed: 1,
        remaining: 2,
        percentage: 33
      },
      user.task_statistics
    )
  end

  test "returns 100 percent when all tasks are completed" do
    user = create_test_user(email: "all-completed@example.com")
    project = create_test_project(user: user)

    first_task = create_test_task(project: project)
    second_task = create_test_task(project: project)

    first_task.update!(status: :done)
    second_task.update!(status: :done)

    assert_equal(
      {
        total: 2,
        completed: 2,
        remaining: 0,
        percentage: 100
      },
      user.task_statistics
    )
  end

  test "returns zero percent when no tasks are completed" do
    user = create_test_user(email: "none-completed@example.com")
    project = create_test_project(user: user)

    create_test_task(project: project, title: "First task")
    create_test_task(project: project, title: "Second task")

    assert_equal(
      {
        total: 2,
        completed: 0,
        remaining: 2,
        percentage: 0
      },
      user.task_statistics
    )
  end

  test "has many projects" do
    user = create_test_user(email: "user-projects@example.com")

    first_project = create_test_project(
      user: user,
      name: "First project"
    )

    second_project = create_test_project(
      user: user,
      name: "Second project"
    )

    assert_equal [first_project, second_project], user.projects.to_a
  end

  test "calculates statistics using only the user's own tasks" do
    user_a = create_test_user(email: "statistics-a@example.com")
    project_a = create_test_project(user: user_a)

    completed_task = create_test_task(project: project_a)
    completed_task.update!(status: :done)
    create_test_task(project: project_a)

    user_b = create_test_user(email: "statistics-b@example.com")
    project_b = create_test_project(user: user_b)

    3.times do
      task = create_test_task(project: project_b)
      task.update!(status: :done)
    end

    assert_equal(
      {
        total: 2,
        completed: 1,
        remaining: 1,
        percentage: 50
      },
      user_a.task_statistics
    )
  end

  test "has many tasks through projects" do
    user = create_test_user(email: "user-tasks@example.com")

    first_project = create_test_project(
      user: user,
      name: "First project"
    )

    second_project = create_test_project(
      user: user,
      name: "Second project"
    )

    first_task = create_test_task(
      project: first_project,
      title: "First task"
    )

    second_task = create_test_task(
      project: second_project,
      title: "Second task"
    )

    assert_equal [first_task, second_task], user.tasks.to_a
  end
end
