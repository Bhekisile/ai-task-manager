class AddStatusIndexToTasks < ActiveRecord::Migration[8.1]
  def change
    add_index :tasks, :status
  end
end
