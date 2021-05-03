class CreateAprStages < ActiveRecord::Migration
  def change
    create_table :apr_stages do |t|
      t.date :begin_date
      t.date :end_date
      t.integer :begin_money
      t.integer :end_money
      t.float :apr
      t.integer :financing_id

      t.timestamps
    end
  end
end
