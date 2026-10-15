require "rails_helper"

RSpec.describe "Tasks", type: :request do
  include Devise::Test::IntegrationHelpers

  describe "PATCH /projects/:project_id/tasks/:id" do
    let(:user) do
      User.create!(
        email: "owner@example.com",
        password: "Password123!",
        role: :member
      )
    end

    let(:project) do
      Project.create!(
        name: "Test Project",
        user: user
      )
    end

    let(:task) do
      project.tasks.create!(
        title: "Original title",
        priority: :medium,
        status: :todo
      )
    end

    it "rejects a stale update without overwriting the latest changes" do
      sign_in user

      # User A saves a change using lock_version 0.
      patch project_task_path(project, task), params: {
        task: {
          title: "Latest saved title",
          lock_version: 0
        }
      }

      expect(response).to have_http_status(:redirect)

      expect(task.reload.title).to eq("Latest saved title")
      expect(task.lock_version).to eq(1)

      # User B submits an outdated form with lock_version 0.
      patch project_task_path(project, task), params: {
        task: {
          title: "Outdated title",
          lock_version: 0
        }
      }

      expect(response).to have_http_status(:conflict)

      expect(response.body).to include(
        "This task was updated by someone else"
      )

      # The newer saved title must remain unchanged.
      expect(task.reload.title).to eq("Latest saved title")
      expect(task.lock_version).to eq(1)
    end

    it "allows the user to retry with the latest lock version" do
      sign_in user

      # First update succeeds, moving the version from 0 to 1.
      patch project_task_path(project, task), params: {
        task: {
          title: "Latest saved title",
          lock_version: 0
        }
      }

      expect(task.reload.lock_version).to eq(1)

      # An outdated submission is rejected.
      patch project_task_path(project, task), params: {
        task: {
          title: "My intended title",
          lock_version: 0
        }
      }

      expect(response).to have_http_status(:conflict)
      expect(task.reload.title).to eq("Latest saved title")

      # The user deliberately retries with the latest version.
      patch project_task_path(project, task), params: {
        task: {
          title: "My intended title",
          lock_version: task.reload.lock_version
        }
      }

      expect(response).to have_http_status(:redirect)
      expect(task.reload.title).to eq("My intended title")
      expect(task.lock_version).to eq(2)
    end

    it "shows the submitted changes and latest version after a conflict" do
      sign_in user

      # Save the first user's changes.
      patch project_task_path(project, task), params: {
        task: {
          title: "Latest saved title",
          lock_version: 0
        }
      }

      # Submit an outdated version.
      patch project_task_path(project, task), params: {
        task: {
          title: "My outdated title",
          lock_version: 0
        }
      }

      expect(response).to have_http_status(:conflict)

      # The conflict page should explain the differences.
      expect(response.body).to include("Your submitted changes")
      expect(response.body).to include("Latest saved Title")
      expect(response.body).to include("Latest saved title")
      expect(response.body).to include("My outdated title")

      # The page should offer a way to deliberately retry.
      expect(response.body).to include("Review and apply my changes")

      # The refreshed form should carry the latest lock version.
      expect(response.body).to include('name="task[lock_version]"')
      expect(response.body).to include('value="1"')
    end

    it "denies an authenticated user who does not own the project" do
      sign_in user

      # Create a different owner and their project.
      other_user = User.create!(
        email: "other-owner@example.com",
        password: "Password123!",
        role: :member
      )

      other_project = Project.create!(
        name: "Other User's Project",
        user: other_user
      )

      other_task = other_project.tasks.create!(
        title: "Private task",
        priority: :medium,
        status: :todo
      )

      # Attempt to update the other user's task.
      patch project_task_path(other_project, other_task), params: {
        task: {
          title: "Unauthorized change",
          lock_version: 0
        }
      }

      # The request must be denied.
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(projects_path)
      expect(flash[:alert]).to eq(
        "You do not have permission to perform this action."
      )

      # The task must remain unchanged.
      expect(other_task.reload.title).to eq("Private task")
      expect(other_task.lock_version).to eq(0)
    end

    it "redirects an unauthenticated visitor to sign in without changing the task" do
      # Arrange: create a task owned by a user.
      owner = User.create!(
        email: "task-owner@example.com",
        password: "Password123!",
        role: :member
      )

      project = Project.create!(
        name: "Protected Project",
        user: owner
      )

      task = project.tasks.create!(
        title: "Private task",
        priority: :medium,
        status: :todo
      )

      # Act: send a PATCH request without signing in.
      patch project_task_path(project, task), params: {
        task: {
          title: "Unauthorized change",
          lock_version: 0
        }
      }

      # Assert: Devise redirects the visitor to sign in.
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_user_session_path)

      # The task must remain unchanged.
      expect(task.reload.title).to eq("Private task")
      expect(task.lock_version).to eq(0)
    end

    it "does not update a task through the wrong project" do
      # Arrange: create two separate owners and projects.
      owner_a = User.create!(
        email: "owner-a@example.com",
        password: "Password123!",
        role: :member
      )

      owner_b = User.create!(
        email: "owner-b@example.com",
        password: "Password123!",
        role: :member
      )

      project_a = Project.create!(
        name: "Project A",
        user: owner_a
      )

      project_b = Project.create!(
        name: "Project B",
        user: owner_b
      )

      task_b = project_b.tasks.create!(
        title: "Task belonging to Project B",
        priority: :medium,
        status: :todo
      )

      sign_in owner_a

      # Act: access Project B's task through Project A's URL.
      patch project_task_path(project_a, task_b), params: {
        task: {
          title: "Unauthorized change",
          lock_version: 0
        }
      }

      # Assert: the nested association cannot find the task.
      expect(response).to have_http_status(:not_found)

      # The task must remain unchanged.
      expect(task_b.reload.title).to eq("Task belonging to Project B")
      expect(task_b.lock_version).to eq(0)
    end
  end
end