class UpdateJobStatusEnum < ActiveRecord::Migration[6.1]
  def change
    change_column :jobs, :status, :integer, default: 0
  end
end