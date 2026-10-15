ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module TestDataHelpers
  def create_test_user(email: "test@example.com")
    User.create!(
      email: email,
      password: "password123",
      password_confirmation: "password123"
    )
  end

  def create_test_project(user:, name: "Test Project")
    user.projects.create!(
      name: name,
      status: :active
    )
  end

  def create_test_task(project:, title: "Test Task")
    project.tasks.create!(
      title: title,
      priority: :medium,
      status: :todo
    )
  end
end

module ActiveSupport
  class TestCase
    include TestDataHelpers
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    # fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
