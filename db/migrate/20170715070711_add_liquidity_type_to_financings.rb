class AddLiquidityTypeToFinancings < ActiveRecord::Migration[4.2]
  def change
    add_column :financings, :liquidity_type, :string
  end
end
