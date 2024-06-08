class AddStateToStores < ActiveRecord::Migration[7.1]
  def change
    add_column :stores, :state, :string
  end
end
