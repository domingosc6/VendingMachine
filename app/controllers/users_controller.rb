class UsersController < ApiController
    include ApplicationHelper
    before_action :require_login, except: [:create]
    before_action :get_user, except: [:create]
    before_action :check_if_buyer, only: [:deposit, :reset]
    
    def create
        user = User.create!(user_params)
        render json: {token: user.auth_token}
    end
    
    def show 
        render_json_profile(user)
    end

    def update
        user = User.update!(user_params)
        render_json_profile(user)
    end

    def deposit
        deposit = user_params[:deposit]
        if CoinsToUse.include? deposit
            user.deposit += deposit
            user.save
        else
            render_error("Deposit should be one coin of #{CoinsToUse.to_sentence(last_word_connector: ' or ')}")
        end
    end

    def reset
        coins_change = get_change_in_coins(user.deposit)
        user.update(deposit: 0)
        render json: {message: "Reset of deposit successful, your return is returned with the following coins: #{coins_change.to_sentence}"}
    end
    
    private
    
    def user_params
        params.require(:user).permit(:username, :password, :name, :email, :role, :deposit)
    end

    def render_json_profile(user)
        render json: {user: {username: user.username, email: user.email, name: user.name}}
    end

    def get_user
        user = User.find_by_auth_token!(request.headers[:token])
        user
    end

    def check_if_buyer
        user.is_buyer?
    end
    
end