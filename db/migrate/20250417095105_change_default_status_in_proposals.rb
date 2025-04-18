class ChangeDefaultStatusInProposals < ActiveRecord::Migration[7.1] # or your Rails version
  def change
    change_column_default :proposals, :status, from: nil, to: 0
  end
end
