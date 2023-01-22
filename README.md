# Rails API (Auth Token)
##### By following this guide, is assumed that you have a good grasp of Rails and CRUD Operations
##### I'll be using C9 and Rails 5 with psql so then the app can be pushed to Heroku. I'm not quite sure if is required to have nodejs but install it, either way it will be useful if you want to use React 

## Hands on Deck !
Start your psql service:
```
$ sudo service postgresql start
```
Create your Application (I'll be using the name 'vending_machine' but you can name your app whatever you want): 
```
rails new vending_machine-G --database=postgresql --api
```
Now, Let's modify the yml file *config/database.yml* so it will take the template0 from psql: 
``` ruby
default: &default
  adapter: postgresql
  encoding: unicode
  template: template0      # Add this line
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
```
Create the database:
```
rails db:create
```
Uncomment ***bcrypt*** in your *./GEMFILE*
``` ruby
gem 'bcrypt', '~> 3.1.7'
```
Create your user model:
```
rails g model user
```
***Now, You can specify additional fiels in your model but we will go simple this time***
After Generation the model, modify the model */db/migrate* (it should be the only file): 
```ruby
class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      
      t.string :username
      t.string :password_digest 
      t.string :email
      t.string :name
      t.string :auth_token

      t.timestamps
    end
  end
end
```
*The bcypt Ruby gem provides you with has_secure_password method. The has_secure_password method encrypts passwords by hashing and salting the passwords and generate ‘password_digest’*
Run the migration:
```
rails db:migrate
```
Now, we want to add some methods to our users model */app/models/user.rb*:
```ruby
class User < ApplicationRecord
    validates_uniqueness_of :username
    has_secure_password 
end
```
*validates_uniqueness_of will ensure the username can't be used twice*
We have to include the methods *authenticate_or_request_with_http_token, authenticate_with_http_token request_http_token_authentication* in our *app/controllers/application_controller.rb* so modify:
```ruby
class ApplicationController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods
end
```
### Adding the functions ###
Let's start by adding the two controllers:
```
rails g controller api 
rails g controller sessions
```
cd to */app/controllers/*  
Modify the Api controller:
``` ruby
class ApiController < ApplicationController
    
    def require_login
        authenticate_token || render_unauthorized("Access Denied")
    end
    
    def current_user
        @current_user ||= authenticate_token
    end
    
    protected
    
    def render_unauthorized(message)
        errors = {errors: [detail: message]}
        render json: errors, status: :unauthorized
    end
    
    private
    
    def authenticate_token
        authenticate_with_http_token do |token, options|
            User.find_by(auth_token: token)
        end
    end
    
end
```
Modify the Sessions Controller(***Note that I'm inheriting ApiController instead of ApplicationConstroller***):
``` ruby
class SessionsController < ApiController
    
    skip_before_action :require_login, only: [:create], raise: false
    
    def create
        if user = User.validate_login(params[:username], params[:password])
            allow_token_to_be_used_only_once_for(user)
            send_token_for_valid_login_of(user)
        else
            render_unauthorized("Error with your login password")
        end
    end
    
    def destroy 
        logout
        head :ok
    end
    
    private
    
    def allow_token_to_be_used_only_once_for(user)
        user.regenerate_auth_token
    end
    
    def send_token_for_valid_login_of(user)
        render json: {token: user.auth_token}
    end
    
    def logout
        current_user.invalidate_token
    end
    
end
```
Define the methods in our User Model */app/models/user.rb*:
``` ruby 
class User < ApplicationRecord
    validates_uniqueness_of :username
    has_secure_password 
    has_secure_token :auth_token
    
    def invalidate_token 
        self.update_columns(auth_token: nil)
    end 
    
    def self.validate_login(username, password)
        user = find_by(username: username)
        
        if user && user.authenticate(password)
            user
        end
    
    end
end
```
Now we should define our Routes:
``` ruby
Rails.application.routes.draw do
    
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'login' => "sessions#create"
  delete '/logout' => "sessions#destroy"
  resources :users
  get '/profile' => "users#profile"
  
end
```
And we have to create a users controller. Run:
```
rails g controller users
```
Now, modify the file generated in */app/controllers/users_controller.rb*(***Note that this also inherits ApiController***):
``` ruby
class UsersController < ApiController
    before_action :require_login, except: [:create]
    
    def create
        user = User.create!(user_params)
        render json: {token: user.auth_token}
    end
    
    def profile 
        user = User.find_by_auth_token!(request.headers[:token])
        render json: {user: {username: user.username, email: user.email, name: user.name}}
    end
    
    private
    
    def user_params
        params.require(:user).permit(:username, :password, :name, :email)
    end
    
end
```
Start the Rails Server by using this command (*If you are not using C9, rails s will work*):
```
rails s -b $IP -p $PORT 
```
By now, we should be able to test it using Postman. Install the Chrome extension-you will see "new tab". The type of request should be POST. In the top right of your workspace, you should see a tab that says "share". Copy the "Application" link and paste in into Postman, where says "Enter request URL". Add /users and we are ready to make the first request. 
Leave all fields in blank except for ***Headers***: key should be *content-type* and value *application/json*.
***Body***: choose raw and instead of text, choose JSON. 
Now enter:
``` json
{
	"user": {
		"username": "john_hardesky",
		"password": "pass123@$",
		"email": "test_email@nasa.gov",
		"name": "BCat"
	}
}
```
A new tab should open showing something like this:
``` json
{
    "token": "1j4LA84aDdyPN3ecKaUtiGJ5"
}
```
Now, copy the token and open a new tab in Postman. Request type is POST and the modify the URL endpoint to /login. Modify the Headers to they will look like this: 
***Key*** ***Value***
Content-Type application/json
token 1j4LA84aDdyPN3ecKaUtiGJ5
Authorization Token 1j4LA84aDdyPN3ecKaUtiGJ5

Put this code in the Body: 

``` json
{
	"username": "john_hardesky",
	"password": "pass123@$"
}
```

You should get the session token.

## Now you can start adding features to your app ##




