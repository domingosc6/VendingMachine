class ProductsController < ApiController
  include ApplicationHelper

  before_action :get_user_by_token, except: [:show]
  before_action :set_product, only: %i[ show update destroy buy ]
  before_action :check_if_stocker, only: %i[ create update destroy ]
  before_action :check_if_buyer, only: :buy

  def index
    @products = Product.all
  end

  def show
    render_json_product
  end

  def create
    @product = Product.new(product_params)
    @product.seller = @user

    if @product.save
      render_json_product
    else
      render_error(@product.errors.to_a.join)
    end
  end

  def update
    if @product.update(product_params)
      render_json_product
    else
      render_error(@product.errors.to_a.join)
    end
  end

  def destroy
    @product.destroy
  end
  
  def buy
    if params[:amount] === params[:amount].to_i.to_s
      amount = Integer(params[:amount])
      total_value = amount * @product.cost
      if @product.amount_available < amount
        render_error('Product requested doesn\'t have enough quantity.')
      elsif total_value > @user.deposit
        render_error('The product value is too high for your purchase.')
      else
        new_amount = @product.amount_available - amount
        @product.update(amount_available: new_amount)
        change = @user.deposit - total_value
        @user.update(deposit: 0)
        change_array = get_change_in_coins(change)
        render json: {change: change_array}
      end
    else
      render_error(@product.errors.to_a.join)
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
    render json: {product: {product_name: @product.product_name, amount_available: @product.amount_available, cost: @product.cost, seller: @product.seller.name}}
  end

end
