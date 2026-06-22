class AddInterestedAtToFinancings < ActiveRecord::Migration[4.2]
  def change
    add_column :financings, :interested_at, :date
  end
end
