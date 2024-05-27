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

    if @order.save
      redirect_to @order, notice: 'Order was successfully created.'
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
    params.require(:order).permit(
      order_items_attributes: [:store_id, :product_id, :quantity, :price])
  end
end
