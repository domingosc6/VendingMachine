class ApiController < ApplicationController
    
    def require_login
        authenticate_token || render_unauthorized('Access Denied')
    end
    
    def current_user
        @current_user ||= authenticate_token
    end
    
    protected
    
    def render_unauthorized(message)
        errors = { errors: [detail: message] }
        render json: errors, status: :unauthorized
    end

    def render_error(message)
        errors = { errors: [detail: message] }
        render json: errors, status: :bad_request
    end
    
    private
    
    def authenticate_token
        authenticate_with_http_token do |token, options|
            User.find_by(auth_token: token)
        end
    end

    def get_user_by_token
        @user = User.find_by_auth_token(request.headers[:token])
        if @user.nil?
            render_unauthorized('Access Denied')
        end
    end

    def check_if_stocker
        render_unauthorized('You don\'t have the necessary role for this action.') unless @user.stocker? || @user.admin?
    end

    def check_if_buyer
        render_unauthorized('You don\'t have the necessary role for this action.') unless @user.buyer? || @user.admin?
    end
    
end