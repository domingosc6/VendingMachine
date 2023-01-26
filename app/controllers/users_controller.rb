class UsersController < ApiController
    include ApplicationHelper

    before_action :get_user_by_token, except: [:create]
    before_action :check_if_buyer, only: [:deposit, :reset]

    def create
        user = User.create!(user_params)
        render json: {token: user.auth_token}
    end
    
    def profile
        render_json_profile
    end

    def index
        if @user.admin?
            #RENDER ALL
        else
            render_unauthorized('Access Denied')
        end
    end

    def update
        @user = User.update!(user_params)
        render_json_profile
    end

    def deposit
        deposit = params[:deposit]
        if deposit === deposit.to_i.to_s && CoinsToUse.include?(deposit.to_i)
            deposit = deposit.to_i
            @user.deposit += deposit
            @user.save
            render_json_profile
        else
            render_error("Deposit should be one coin of #{CoinsToUse.to_sentence(last_word_connector: ' or ')}")
        end
    end

    def reset
        old_deposit = @user.deposit
        if old_deposit.zero?
            render_unauthorized("You don\'t have any deposit in your profile.")
        else
            coins_change = get_change_in_coins(@user.deposit)
            @user.update(deposit: 0)
            render json: {message: "Reset of deposit of value #{old_deposit} successful, your return is returned with the following coins: #{coins_change.to_sentence}"}
        end
    end
    
    private
    
    def user_params
        params.require(:user).permit(:username, :password, :name, :email, :role, :deposit)
    end

    def render_json_profile
        render json: {user: {username: @user.username, email: @user.email, name: @user.name, role: @user.role, deposit: @user.deposit}}
    end
    
end