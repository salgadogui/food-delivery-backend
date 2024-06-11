class StoresController < ApplicationController
  before_action :authenticate!
  before_action :set_store, only: %i[ show edit update destroy toggle_state]
  skip_forgery_protection only: [:create]
  skip_before_action :verify_authenticity_token, only: [:destroy, :update, :toggle_state]

  def index
    if current_user.admin?
      @stores = Store.all
    elsif current_user.seller?
      @stores = Store.kept.where(user: current_user)
    elsif current_user.buyer?
      @stores = Store.kept
    end

    respond_to do |format|
      format.html
      format.json { render json: @stores, status: :ok }
    end
  end

  def show
  end

  def new
    @store = Store.new
  end

  def edit
  end

  def create
    @store = Store.new(store_params)
    @store.user = current_user

    respond_to do |format|
      if @store.save
        format.html { redirect_to store_url(@store), notice: "Store was successfully created." }
        format.json { render :show, status: :created, location: @store }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @store.undiscard if params.dig(:restore)

    respond_to do |format|
      if @store.update(store_params)
        format.html { redirect_to store_url(@store), notice: "Store was successfully updated." }
        format.json { render :show, status: :ok, location: @store }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @store.discard

    respond_to do |format|
      format.html { redirect_to stores_url, notice: "Store was successfully discarded." }
      format.json { render :show, status: :ok, location: @store }
    end
  end

  def toggle_state
    if @store.closed?
      @store.open_store
    else
      @store.close_store
    end

    if @store.save
      render json: @store, status: :ok
    else
      render json: @store.errors, status: :unprocessable_entity
    end
  end

  private
    def set_store
      @store = Store.find(params[:id])
    end

    def store_params
      required = params.require(:store)

      if current_user.admin?
        required.permit(:name, :user)
      else
        required.permit(:name)
      end
    end
end
