require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "is invalid without a name" do
    user = create_test_user(email: "blank-project@example.com")

    project = Project.new(
      name: "",
      status: :active,
      user: user
    )

    assert_not project.valid?
    assert_includes project.errors[:name], "can't be blank"
  end

  test "is valid with a name and user" do
    user = create_test_user(email: "valid-project@example.com")

    project = Project.new(
      name: "Testing Rails",
      status: :active,
      user: user
    )

    assert project.valid?, project.errors.full_messages.to_sentence
  end

  test "accepts a valid status" do
    project = Project.new(status: :archived)

    assert_equal "archived", project.status
  end

  test "persists its archived status in the database" do
    user = create_test_user(email: "archived-project@example.com")

    project = user.projects.create!(
      name: "Archived project",
      status: :archived
    )

    saved_project = Project.find(project.id)

    assert_equal "archived", saved_project.status
  end

  test "has many tasks" do
    user = create_test_user(email: "project-tasks@example.com")
    project = create_test_project(user: user)

    first_task = create_test_task(
      project: project,
      title: "First task"
    )

    second_task = create_test_task(
      project: project,
      title: "Second task"
    )

    assert_equal [first_task, second_task], project.tasks.to_a
  end

  test "returns only its own tasks" do
    user = create_test_user(email: "separate-tasks@example.com")

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
      title: "First project's task"
    )

    create_test_task(
      project: second_project,
      title: "Second project's task"
    )

    assert_equal [first_task], first_project.tasks.to_a
  end

  test "updates tasks_count when a task is created" do
    user = create_test_user(email: "counter-cache@example.com")
    project = create_test_project(user: user)

    assert_equal 0, project.tasks_count

    create_test_task(project: project, title: "First task")

    assert_equal 1, project.reload.tasks_count
  end

  test "updates tasks_count when a task is destroyed" do
    user = create_test_user(email: "counter-destroy@example.com")
    project = create_test_project(user: user)

    task = create_test_task(project: project)

    assert_equal 1, project.reload.tasks_count

    task.destroy!

    assert_equal 0, project.reload.tasks_count
  end

  test "can be archived" do
    user = create_test_user(email: "archive-project@example.com")
    project = create_test_project(user: user)

    project.update!(status: :archived)

    assert_equal "archived", project.reload.status
  end

  test "is invalid without a user" do
    project = Project.new(
      name: "Unowned project",
      status: :active
    )

    assert_not project.valid?
    assert_includes project.errors[:user], "must exist"
  end
end
