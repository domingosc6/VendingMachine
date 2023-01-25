class ApiController < ApplicationController
    
    def require_login
        authenticate_token || render_unauthorized("Access Denied")
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
            debugger
            User.find_by(auth_token: token)
        end
    end
    
end