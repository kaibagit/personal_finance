class AddTimeToLiquidityToFinancings < ActiveRecord::Migration[5.0]
  def change
    add_column :financings, :time_to_liquidity, :string, default: 'unknown'

    # 历史记录刷成"未知"（SQLite 不会给已有行回填 default）
    Financing.reset_column_information
    Financing.where(time_to_liquidity: nil).update_all(time_to_liquidity: 'unknown')
  end
end
