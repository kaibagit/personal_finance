class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.integer :channel_id
      t.string :way
      t.integer :cent
      t.datetime :happened_at

      t.timestamps
    end
  end
end
