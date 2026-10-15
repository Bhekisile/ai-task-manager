require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  
  test "should get index" do
    user = User.create!(
      email: "dashboard-test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    sign_in user

    get dashboard_index_url

    assert_response :success
  end
end
