class OrdersController < ApplicationController
  include ActionController::Live

  before_action :authenticate!
  before_action :find_store, only: [:new, :create]
  before_action :check_store_state, only: [:create]
  skip_forgery_protection only: [:create]


  def status
    @order = Order.find(params[:id])

    response.headers['Content-Type'] = 'text/event-stream'
    sse = ActionController::Live::SSE.new(response.stream, retry: 300, event: "order-status")

    begin
      loop do
        sse.write({ status: @order.state, order_id: @order.id }, event: "order-status")
        sleep(5) 
      end
    rescue IOError, ActionController::Live::ClientDisconnected
      sse.close
    ensure
      sse.close
    end
  end

  def update_status
    @order = Order.find(params[:id])
    case params[:status]
      when 'out_for_delivery'
        @order.deliver_order
      when 'order_delivered'
        @order.close_order
        handle_order_completion(@order, sse)
      else
        render json: { error: 'Invalid status' }, status: :unprocessable_entity
        return
    end

    if @order.save
      response.headers['Content-Type'] = 'text/event-stream'
      sse = ActionController::Live::SSE.new(response.stream, retry: 300, event: "order-status")
      begin
        sse.write({ status: @order.state, order_id: @order.id }, event: "order-status")
      rescue IOError
        handle_disconnect(@order, sse)
      ensure
        sse.close
      end
      render json: { status: @order.state, order_id: @order.id }, status: :ok
    else
      render json: { error: 'Failed to update order status' }, status: :unprocessable_entity
    end
  end

  def index
    if current_user.admin?
      @orders = Order.includes(:store, :order_items)
    elsif current_user.seller?
      @orders = Order.includes(:store, :order_items)
        .where(store: current_user.stores.kept)
    elsif current_user.buyer?
      @orders = Order.includes(:user)
        .where(user_id: current_user.id)
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
      params.require(:order).permit(:id, :user_id,
        order_items_attributes: [:id, :product_id, :quantity])
    end

    def payment_params
      params.require(:payment).permit(:value, :number, :valid, :cvv)
    end

    def handle_order_completion(order, sse)
      sse.close if order.state == 'delivered' || order.state == 'canceled'
    end

    def handle_disconnect(order, sse)
      order.cancel_order unless order.state == 'delivered'
      sse.close
    end

    def check_store_state
      if @store.closed?
        render json: { error: "Store is closed and cannot accept any orders." }, status: :forbidden
      end
    end
end
