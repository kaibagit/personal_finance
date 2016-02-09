class AddRiskToFinancings < ActiveRecord::Migration
  def change
    add_column :financings, :risk, :string
  end
end
