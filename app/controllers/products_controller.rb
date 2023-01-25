class ProductsController < ApplicationController
  include ApplicationHelper

  before_action :require_login, except: [:show]
  before_action :set_product, only: %i[ show update destroy buy ]
  before_action :check_role_from_user, only: :create
  before_action :check_user, only: %i[ update destroy ]

  def index
    @products = Product.all
  end

  def show
    render_json_product
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
      amount = params[:ammount]
      total_value = amount * @product.cost

      if @product.amount_available < amount
        @product.errors.add(parameters[:amount_available], 'is not sufficient for your purchase')
        render json: @product.errors, status: :bad_request
      elsif total_value < @current_user.deposit
        @product.errors.add(parameters[:cost], 'is high enough for your purchase')
        render json: @product.errors, status: :bad_request
      else
        @product.amount_available -= amount
        change = @user.deposit - total_value
        @user.deposit = 0
        change_array = get_change_in_coins(change)
        render json: {change: change_array}
      end
      
  end

  private
  
  def set_product
    product_id = params[:id] || params[:product_id]
    @product = Product.find(product_id)
  end

  def product_params
    params.require(:product).permit(:product_name, :amount_available, :cost)
  end

  def render_json_product
    render json: {product: {product_name: product.product_name, amount_available: product.amount_available, cost: product.cost, seller: product.seller.name}}
  end

end
