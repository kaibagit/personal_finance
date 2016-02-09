class AddInterestedAtToFinancings < ActiveRecord::Migration
  def change
    add_column :financings, :interested_at, :date
  end
end
