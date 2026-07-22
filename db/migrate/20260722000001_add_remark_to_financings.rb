class AddRemarkToFinancings < ActiveRecord::Migration[5.0]
  def change
    add_column :financings, :remark, :string
  end
end
