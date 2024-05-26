class OrdersController < ApplicationController
  def new
    @store = Store.find(params[:store_id])
    @order = @store.orders.new
    @order.order_items.build
  end

  def create
    @store = Store.find(params[:store_id])
    @order = @store.orders.new(order_params)
    @order.user = current_user

    @order.order_items.each do |item|
      item.price = item.product.price
    end

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

  def order_params
    params.require(:order).permit(order_items_attributes: [:product_id, :quantity, :price])
  end
end
