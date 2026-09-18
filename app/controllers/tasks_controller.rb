class TasksController < ApplicationController
  before_action :set_project, only: [:new, :create, :show, :edit, :update, :destroy, :complete]
  before_action :set_task, only: [:show, :edit, :update, :destroy, :complete]
  after_action :verify_authorized

  def new
    @task = @project.tasks.new
    authorize @task
  end

  def create
    @task = @project.tasks.new(task_params)
    authorize @task

    if @task.save
      redirect_to @project, notice: "Task created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @task
  end

  def update
    authorize @task
    if @task.update(task_params)
      redirect_to [@project, @task], notice: "Task updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @task
    @task.destroy
    redirect_to @project, notice: "Task was successfully deleted"
  end

  def complete
    authorize @task
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