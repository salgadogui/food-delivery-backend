class ProductsController < ApplicationController
  before_action :authenticate!

  def index
    if current_user.admin?
      @products = Product.includes(:store)
    else
      @products = Product.includes(:store).where(store: current_user.stores)
    end

    respond_to do |format|
      format.html
      format.json { render json: @products, status: :ok }
    end
  end

  def show
    # modificar para procurar por product_id e store_id
    @product = Product.find_by(
      id: params[:id], store_id: params[:store_id])
  end

  private

    def product_params
      params.require(:product).permit(:name, :price, :store_id)
    end
end
