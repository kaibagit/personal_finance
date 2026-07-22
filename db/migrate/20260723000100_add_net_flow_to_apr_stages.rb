class AddNetFlowToAprStages < ActiveRecord::Migration[5.0]
  def change
    add_column :apr_stages, :net_flow, :integer
  end
end
