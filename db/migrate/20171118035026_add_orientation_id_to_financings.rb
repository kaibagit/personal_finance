class AddOrientationIdToFinancings < ActiveRecord::Migration[4.2]
  def change
    add_column :financings, :orientation_id, :integer
  end
end
