class AddValuationMethodToFinancings < ActiveRecord::Migration[5.0]
  def change
    add_column :financings, :valuation_method, :string, default: 'legacy', null: false
  end
end
