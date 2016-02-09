class AddHorizonToFinancings < ActiveRecord::Migration
  def change
    add_column :financings, :horizon, :float
  end
end
