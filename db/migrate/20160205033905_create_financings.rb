class CreateFinancings < ActiveRecord::Migration
  def change
    create_table :financings do |t|
      t.integer :channel_id
      t.string :name
      t.float :exp_rate
      t.integer :money_cent
      t.datetime :paid_at
      t.string :status
      t.date :exp_antedated
      t.date :act_antedated
      t.float :act_rate
      t.integer :exp_earning
      t.integer :act_earning

      t.timestamps
    end
  end
end
