class AddEffectiveToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :effective, :boolean
  end
end
