class ChangeProposalStatusDefault < ActiveRecord::Migration[6.1]
  def change
    change_column_default :proposals, :status, from: "0", to: "pending"
  end
end