class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
