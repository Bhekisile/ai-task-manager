class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def require_admin
    unless current_user.admin?
      redirect_to projects_path, notice: "You do not have permission to delete this project"
    end
  end
end
