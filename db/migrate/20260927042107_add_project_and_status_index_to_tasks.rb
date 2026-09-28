class AddProjectAndStatusIndexToTasks < ActiveRecord::Migration[8.1]
  def change
    add_index :tasks, [:project_id, :status]
  end
end
