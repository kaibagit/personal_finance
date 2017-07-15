class AddLiquidityTypeToFinancings < ActiveRecord::Migration
  def change
    add_column :financings, :liquidity_type, :string
  end
end
