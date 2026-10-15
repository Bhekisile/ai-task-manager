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
end
