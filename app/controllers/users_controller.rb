class UsersController < ApiController
    before_action :require_login, except: [:create]
    before_action :get_user, except: [:create]
    
    def create
        user = User.create!(user_params)
        render json: {token: user.auth_token}
    end
    
    def profile 
        render_json_profile(user)
    end

    def update
        user = User.update!(user_params)
        render_json_profile(user)
    end

    def deposit
        deposit = user_params[:deposit]
        if [5, 10, 20, 50, 100].include? deposit
            user.deposit += deposit
            user.save
        else
            render_error('Deposit should be one coin of 5, 10, 20, 50 or 100')
        end
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
    
end