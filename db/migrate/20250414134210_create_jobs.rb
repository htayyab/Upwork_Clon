class CreateJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :jobs do |t|
      t.string :title
      t.text :description
      t.decimal :budget
      t.integer :status, default: 0  # 'open' as default
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
