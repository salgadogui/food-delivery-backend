class OrdersController < ApplicationController
  before_action :authenticate!
  before_action :find_store, only: [:new, :create]
  before_action :check_store_state, only: [:create, :update]
  skip_forgery_protection only: [:create]

  def index
    if current_user.admin?
      @orders = Order.includes(:store, :order_items)
    else
      @orders = Order.includes(:store, :order_items)
        .where(store: current_user.stores.kept)
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
    @store = Store.kept.find(params[:store_id])
    @order = Order.find_by(
      id: params[:id], store_id: params[:store_id])
  end

  private

    def find_store
      @store = Store.kept.find(params[:store_id])
    end

    def order_params
      params.require(:order).permit(:user_id,
        order_items_attributes: [:id, :product_id, :quantity])
    end

    def check_store_state
      if @store.closed?
        render json: { error: "Store is closed and cannot accept any orders." }, status: :forbidden
      end
    end
end
