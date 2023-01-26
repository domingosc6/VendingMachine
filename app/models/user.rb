class User < ApplicationRecord
    include CostValidation

    has_many :products, foreign_key: :seller_id

    has_secure_password 
    has_secure_token :auth_token

    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates_uniqueness_of :username, :email
    validates_numericality_of :deposit, greater_than_or_equal_to: 0
    validate -> { validate_multipleness(value: self.deposit, multiple: 5, variable: :deposit) }

    enum :role, {admin: 0, buyer: 1, stocker: 2}
    
    def invalidate_token 
        update_columns(auth_token: nil)
    end 
    
    def validate_login(password)
        if auth_token.nil?
            if authenticate(password)
            end
        else
            errors.add(:auth_token, 'Login already made for this user, please clear all your sessions.')
        end
    end
end