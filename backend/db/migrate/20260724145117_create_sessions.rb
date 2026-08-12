class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.timestamps
      t.string :description
      t.integer :duration
      t.datetime :start_time
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
    end
  end
end
