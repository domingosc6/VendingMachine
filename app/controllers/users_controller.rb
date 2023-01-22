class UsersController < ApiController
    before_action :require_login, except: [:create]
    
    def create
        user = User.create!(user_params)
        render json: {token: user.auth_token}
    end
    
    def profile 
        user = User.find_by_auth_token!(request.headers[:token])
        render_json_profile(user)
    end

    def update
        user = User.update!(user_params)
        render_json_profile(user)
    end
    
    private
    
    def user_params
        params.require(:user).permit(:username, :password, :name, :email)
    end

    def render_json_profile(user)
        render json: {user: {username: user.username, email: user.email, name: user.name}}
    end
    
end