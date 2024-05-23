class ProductsController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.admin?
      @products = Product.includes(:store)
    else
      @products = Product.includes(:store).where(store: current_user.stores)
    end
  end

  #   if !current_user.admin?
  #     redirect_to root_path, notice: "No permission for you!"
  #   end

  # @products = Product.includes(:store)

  def show
    @product = Product.find(product_params[:id])
  end

  private

    def product_params
      params.require(:product).permit(:name, :price, :store)
    end
end
