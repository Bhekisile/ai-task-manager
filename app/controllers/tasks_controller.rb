class TasksController < ApplicationController
  before_action :set_project

  def new
    @task = @project.tasks.new
  end

  def create
    @task = @project.tasks.new(task_params)

    if @task.save
      redirect_to @project, notice: "Task created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def task_params
    params.require(:task).permit(
      :title,
      :description,
      :due_date,
      :estimated_minutes,
      :priority,
      :status
    )
  end
end