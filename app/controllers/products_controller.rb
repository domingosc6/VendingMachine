class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show update destroy ]
  before_action :check_role_from_user, only: :create
  before_action :check_user, only: %i[ update destroy ]

  def index
    @products = Product.all
  end

  def show
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      render :show, status: :created, location: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      render :show, status: :ok, location: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
  end
  
  def buy 
        
  end

  private
  
  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:product_name, :amount_available, :cost)
  end
end
