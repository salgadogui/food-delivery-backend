class RenameTitleToNameInProducts < ActiveRecord::Migration[7.1]
  def change
    rename_column :products, :title, :name
  end
end
