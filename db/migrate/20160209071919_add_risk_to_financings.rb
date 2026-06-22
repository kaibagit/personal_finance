class AddRiskToFinancings < ActiveRecord::Migration[4.2]
  def change
    add_column :financings, :risk, :string
  end
end
