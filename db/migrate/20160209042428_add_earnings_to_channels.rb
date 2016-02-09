class AddEarningsToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :earnings, :integer
  end
end
