class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.timestamps
      t.string :name
      t.references :user, null: false, foreign_key: true
    end
  end
end
