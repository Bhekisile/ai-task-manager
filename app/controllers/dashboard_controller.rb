class DashboardController < ApplicationController  
  def index
    @statistics = current_user.task_statistics
  end
end
