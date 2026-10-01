class CreateNotificationDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_deliveries do |t|
      t.references :task, null: false, foreign_key: true
      t.string :notification_type
      t.datetime :sent_at

      t.timestamps
    end

    add_index :notification_deliveries,
          [:task_id, :notification_type],
          unique: true
  end
end
