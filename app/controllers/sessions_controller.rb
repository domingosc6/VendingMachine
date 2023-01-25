class SessionsController < ApiController

  skip_before_action :require_login, only: [:create], raise: false
  
  def create
    user = User.validate_login(params[:username], params[:password])
    if user && user.errors.empty?
      allow_token_to_be_used_only_once_for(user)
      send_token_for_valid_login_of(user)
    elsif user.errors[:auth_token].present?
      render_unauthorized(user.errors[:auth_token])
    else
      render_unauthorized('Error with your login password')
    end
  end
  
  def destroy
    current_user = User.validate_login(params[:username], params[:password])
    if current_user.auth_token.present?
      current_user.invalidate_token
      render json: { message: 'Logout successful!' }
    else
      render json: { message: 'The current user doesn\'t have login sessions.' }
    end
    
  end
  
  private
  
  def allow_token_to_be_used_only_once_for(user)
    user.regenerate_auth_token
  end
  
  def send_token_for_valid_login_of(user)
    render json: { token: user.auth_token }
  end
  
end