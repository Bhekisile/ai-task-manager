class MakeUserRequiredOnProjects < ActiveRecord::Migration[8.1]
  def change
    change_column_null :projects, :user_id, false
  end
end
