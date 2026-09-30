class CreateActivityLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_logs do |t|
      t.references :task, null: false, foreign_key: true
      t.string :action

      t.timestamps
    end
  end
end
