class SessionsController < ApiController
  before_action :get_user
  skip_before_action :require_login, only: [:create], raise: false

  def create
    if @user.present? && @user.errors.empty?
      allow_token_to_be_used_only_once_for(@user)
      send_token_for_valid_login_of(@user)
    elsif @user.errors[:auth_token].present?
      render_unauthorized(@user.errors[:auth_token])
    elsif @user.errors[:password].present?
      render_unauthorized(@user.errors[:password].to_sentence)
    else
      render_unauthorized('System error, please contact admin')
    end
  end

  def destroy
    if @user.present? && @user.auth_token.present?
      @user.invalidate_token
      render json: { message: 'Logout successful!' }
    else
      render json: { message: 'The current user doesn\'t have login sessions.' }
    end
  end

  private

  def get_user
    @user = User.find_by(username: params[:username])
    if @user.present?
      @user.validate_login(params[:password])
    end
  end
  
  def allow_token_to_be_used_only_once_for(user)
    user.regenerate_auth_token
  end
  
  def send_token_for_valid_login_of(user)
    render json: { token: user.auth_token }
  end

end
