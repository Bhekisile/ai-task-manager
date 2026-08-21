class TasksController < ApplicationController
  before_action :set_project, only: [:new, :create, :show, :edit, :update, :destroy, :complete]
  before_action :set_task, only: [:show, :edit, :update, :destroy, :complete]

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

  def show
  end

  def update
    if @task.update(task_params)
      redirect_to [@project, @task], notice: "Task updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to @project, notice: "Task was successfully deleted"
  end

  def complete
    @task.done!
    redirect_to [@project, @task]
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:id])
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