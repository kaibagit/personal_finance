class CreateFinancingItems < ActiveRecord::Migration
  def change
    create_table :financing_items do |t|
      t.integer :financing_id
      t.integer :money_cent
      t.datetime :paid_at
      t.date :interested_at

      t.timestamps
    end
  end
end
