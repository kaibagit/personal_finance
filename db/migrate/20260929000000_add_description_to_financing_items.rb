class AddDescriptionToFinancingItems < ActiveRecord::Migration[5.0]
  def change
    add_column :financing_items, :description, :text
  end
end
