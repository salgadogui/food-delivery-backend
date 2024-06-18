class Order < ApplicationRecord
  belongs_to :user
  belongs_to :store
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  accepts_nested_attributes_for :order_items
  before_save :calculate_total_value
  before_validation :ensure_user_is_buyer

  state_machine initial: :order_placed do
    state :order_placed
    state :order_confirmed
    state :preparing_order
    state :out_for_delivery
    state :delivered
    state :canceled

    event :confirm_order do
      transition order_placed: :order_confirmed
    end

    event :prepare_order do
      transition order_confirmed: :preparing_order
    end

    event :deliver_order do
      transition preparing_order: :out_for_delivery
    end

    event :close_order do
      transition out_for_delivery: :delivered
    end

    event :cancel_order do
      transition any - [:delivered, :canceled] => :canceled
    end
  end

  include Discard::Model
  scope :kept, -> { undiscarded.joins(:store).merge(Store.kept) }

  def kept?
    undiscarded? && store.kept?
  end

  private

    def calculate_total_value
      self.total_value = order_items.sum { |item| item.price * item.quantity }
    end

    def ensure_user_is_buyer
      errors.add(:user, "must be a buyer to create an order") unless (user&.buyer? || user&.admin?)
    end
end
