class AddPreAprToFinancingItems < ActiveRecord::Migration[5.0]
  def change
    unless column_exists?(:financing_items, :pre_apr)
      add_column :financing_items, :pre_apr, :float
    end
  end
end
