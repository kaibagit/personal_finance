class AddHorizonUnitToFinancings < ActiveRecord::Migration
  def change
    add_column :financings, :horizon_unit, :string
  end
end
