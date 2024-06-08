class Store < ApplicationRecord
  belongs_to :user
  has_many :products
  has_many :orders
  before_validation :ensure_seller
  validates :name,
            presence: true,
            length: { minimum: 3 }
  include Discard::Model

  state_machine initial: :closed do
    state :open
    state :closed

    event :open_store do
      transition closed: :open
    end

    event :close_store do
      transition open: :closed
    end
  end 

  private

    def ensure_seller
      self.user = nil if self.user && !self.user.seller?
    end
end
