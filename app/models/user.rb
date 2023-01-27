class User < ApplicationRecord
    include CostValidation

    has_many :products, foreign_key: :seller_id

    has_secure_password 
    has_secure_token :auth_token

    validates :username, presence: true
    validates :password, presence: true, on: :create
    validates :role, presence: true
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates_uniqueness_of :username, :email
    validates_numericality_of :deposit, greater_than_or_equal_to: 0
    validate -> { validate_multipleness(value: self.deposit, multiple: 5, variable: :deposit) }

    enum :role, {admin: 0, buyer: 1, stocker: 2}
    
    def invalidate_token 
        update_columns(auth_token: nil)
    end 
    
    def validate_login(password_from_session)
        if auth_token.nil?
            unless authenticate(password_from_session)
                errors.add(:password, 'Incorrect password, please try again.') 
            end
        else
            errors.add(:auth_token, 'Login already made for this user, please clear all your sessions.')
        end
    end

    def profile_in_json(from_admin = false)
        if (from_admin)
            return {user: {username: username, email: email, role: role, deposit: deposit, id: id}}
        else
            return {user: {username: username, email: email, role: role, deposit: deposit}}
        end
    end
end