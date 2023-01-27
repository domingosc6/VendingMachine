class UsersController < ApiController
    include ApplicationHelper

    before_action :get_user_by_token, except: [:create]
    before_action :check_if_buyer, only: [:deposit, :reset]
    before_action :check_if_admin, only: [:index, :destroy]

    def create
        user = User.new(user_params)
        if user.save
            render json: {token: user.auth_token}
        else
            render_error(user.errors.to_a.to_sentence(last_word_connector: ' and '))
        end
    end
    
    def profile
        render_json_profile
    end

    def index
        json_array = []
        if User.any?

            User.all.order(:id).each do |user|
                json_array << user.profile_in_json(true)
            end
            
            render json: json_array
        else
            render json: { message: 'There aren\'t users in the database.' }
        end
    end

    def update
        @user.assign_attributes(user_params)
        if @user.save
            render_json_profile
        else
            render_error(@user.errors.to_a.to_sentence(last_word_connector: ' and '))
        end
    end

    def destroy
        user_to_destroy = User.find_by_id(params[:id])
        if user_to_destroy&.id != @user.id
            if user_to_destroy.present? 
                if user_to_destroy.destroy
                    render json: { message: "User with id #{params[:id]} destroyed succesfully" }
                else
                    render_error(user_to_destroy.errors.to_a.to_sentence(last_word_connector: ' and '))
                end
            else
                render_error('User not found')
            end
        else
            render_error('Can\'t delete an admin user.')
        end
    end

    def deposit
        deposit = params[:deposit]
        if deposit.to_s === deposit.to_i.to_s && CoinsToUse.include?(deposit.to_i)
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
        params.require(:user).permit(:username, :password, :email, :role, :deposit)
    end

    def render_json_profile
        render json: @user.profile_in_json
    end
end