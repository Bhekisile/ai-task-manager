class ProjectsController < 
  before_action :set_project, only: [:show, :edit, :update]
  before_action :require_admin, only: [:destroy]
  before_action :set_project_for_admin, only: [:destroy]

  def index
    @projects = current_user.projects
  end

  def new
    @project = Project.new
  end

  def create
    @project = current_user.projects.new(project_params)

    if @project.save
      redirect_to projects_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project,
                  notice: "Project updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy

    redirect_to projects_path,
                notice: "Project deleted successfully."
  end

  private

  def project_params
    params.require(:project).permit(
      :name,
      :description
    )
  end

  def set_project
    @project = current_user.projects.find(params[:id])
  end

  def set_project_for_admin
    @project = Project.find(params[:id])
  end
end
