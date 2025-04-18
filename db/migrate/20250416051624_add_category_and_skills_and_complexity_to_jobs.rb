class AddCategoryAndSkillsAndComplexityToJobs < ActiveRecord::Migration[8.0]
  def change
    add_column :jobs, :category_id, :integer, null: false
    add_column :jobs, :skills, :text
    add_column :jobs, :complexity, :integer, default: 0

    add_index :jobs, :category_id
  end
end
