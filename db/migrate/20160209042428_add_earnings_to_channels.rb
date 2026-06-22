class AddEarningsToChannels < ActiveRecord::Migration[4.2]
  def change
    add_column :channels, :earnings, :integer
  end
end
