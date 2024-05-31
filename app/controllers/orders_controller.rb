class OrdersController < ApplicationController
  before_action :authenticate!
  before_action :find_store, only: [:new, :create]
  skip_forgery_protection only: [:create]

  def index
    if current_user
      puts "Has current_user"
    else
      puts "Has no current_user"
    end
    if current_user.admin?
      @orders = Order.includes(:store)
    else
      @orders = Order.includes(:store)
        .where(store: current_user.stores.kept)
    end

    respond_to do |format|
      format.html
      format.json { render json: @orders, status: :ok }
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
      @store = Store.kept.find(params[:store_id])
    end

    def order_params
      params.require(:order).permit(:user_id, :store_id,
        order_items_attributes: [:id, :product_id, :quantity])
    end
end
