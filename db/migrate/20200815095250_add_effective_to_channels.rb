class AddEffectiveToChannels < ActiveRecord::Migration[4.2]
  def change
    add_column :channels, :effective, :boolean
  end
end
