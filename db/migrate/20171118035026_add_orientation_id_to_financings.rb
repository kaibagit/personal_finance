class AddOrientationIdToFinancings < ActiveRecord::Migration
  def change
    add_column :financings, :orientation_id, :integer
  end
end
