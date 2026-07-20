class AddMarketValueCentToFinancingItems < ActiveRecord::Migration[5.0]
  def change
    add_column :financing_items, :market_value_cent, :integer
  end
end
