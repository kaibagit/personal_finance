class AddHorizonToFinancings < ActiveRecord::Migration[4.2]
  def change
    add_column :financings, :horizon, :float
  end
end
