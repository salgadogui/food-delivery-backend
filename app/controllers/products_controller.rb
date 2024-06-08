class ProductsController < ApplicationController
  before_action :authenticate!
  skip_forgery_protection only: [:create]
  skip_before_action :verify_authenticity_token, only: [:destroy, :update]

  def index
    if current_user.admin?
      @products = Product.includes(:store)
    else
      @products = Product.includes(:store)
        .where(store: current_user.stores.kept)
    end

    respond_to do |format|
      format.html
      format.json { render json: @products, status: :ok }
    end
  end

  def show
    @store = Store.find(params[:store_id])
    @product = Product.find_by(
      id: params[:id], store_id: params[:store_id])
  end

  def new
    @product = Product.new
  end

  def create
    @store = Store.find(params[:store_id])
    @product = @store.products.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to store_products_path(@store), notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @store }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @store = Store.find(params[:store_id])
    @product = Product.find(params[:id])

    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to store_product_path(@store, @product), notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: store_product_url(@store, @product) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @store = Store.find(params[:store_id])
    @product = Product.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.html { redirect_to products_url, notice: "Product was successfully destroyed." }
      format.json { render :show, status: :ok, location: store_product_url(@store, @product) }
    end
  end

  private

    def product_params
      params.require(:product).permit(:name, :price, :store_id)
    end
end
