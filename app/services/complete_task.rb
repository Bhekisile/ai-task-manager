class CompleteTask
  def self.call(task)
    new(task).call
  end

  def initialize(task)
    @task = task
  end

  def call
    return false if @task.done?

    @task.done!

    true
  end
end
