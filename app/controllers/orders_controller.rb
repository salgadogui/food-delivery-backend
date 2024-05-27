class OrdersController < ApplicationController
  before_action :find_store, only: [:new, :create]

  def index
    if current_user.admin?
      @orders = Order.all
    else
      @orders = Order.where(user: current_user)
    end
  end

  def new
    @order = @store.orders.new
    @order.order_items.build
  end

  def create
    @order = @store.orders.new(order_params)
    @order.user = current_user

    @order.order_items.each do |item|
      item.price = item.product.price
    end

    if @order.save
      redirect_to store_order_path(@store, @order), notice: 'Order was successfully created.'
    else
      render :new
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  private

  def find_store
    @store = Store.find(params[:store_id])
  end

  def order_params
    params.require(:order).permit(:id, :user_id, :store_id,
      order_items_attributes: [:id, :product_id, :quantity])
  end
end
