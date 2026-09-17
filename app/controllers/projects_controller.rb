class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  after_action :verify_policy_scoped, only: :index
  after_action :verify_authorized, except: :index

  def index
    @projects = policy_scope(Project)
  end

  def new
    @project = current_user.projects.new
    authorize @project
  end

  def create
    @project = current_user.projects.new(project_params)
    authorize @project

    if @project.save
      redirect_to projects_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @project
  end

  def edit
    authorize @project
  end

  def update
    authorize @project
    if @project.update(project_params)
      redirect_to @project,
                  notice: "Project updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @project
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
end
