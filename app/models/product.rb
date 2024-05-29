class Product < ApplicationRecord
  belongs_to :store

  include Discard::Model
  scope :kept, -> { undiscarded.joins(:store).merge(Store.kept) }

  def kept?
    undiscarded? && store.kept?
  end
end
