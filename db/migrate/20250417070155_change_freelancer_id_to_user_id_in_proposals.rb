class ChangeFreelancerIdToUserIdInProposals < ActiveRecord::Migration[6.1]
  def change
    # Remove old foreign key constraint
    remove_foreign_key :proposals, column: :freelancer_id

    # Rename the column
    rename_column :proposals, :freelancer_id, :user_id

    # Add new foreign key constraint
    add_foreign_key :proposals, :users
  end
end