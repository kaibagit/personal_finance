class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string :name
      t.integer :total_cent

      t.timestamps
    end
  end
end
