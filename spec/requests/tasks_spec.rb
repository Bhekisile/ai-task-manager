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
  end
end