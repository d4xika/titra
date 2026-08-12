class ChangeProjectIdNullOnSessions < ActiveRecord::Migration[8.1]
  def change
    change_column_null :sessions, :project_id, true
  end
end
