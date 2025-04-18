class AddHoldAmountToProposals < ActiveRecord::Migration[8.0]
  def change
    add_column :proposals, :hold_amount, :decimal, precision: 10, scale: 2
  end
end
