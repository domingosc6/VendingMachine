class User < ApplicationRecord
    include CostValidation

    validates_uniqueness_of :username
    has_secure_password 
    has_secure_token :auth_token
    has_many :products, foreign_key: :seller_id
    validates_numericality_of :deposit, greater_than_or_equal_to: 0
    validate -> { validate_multipleness(value: self.deposit, multiple: 5, variable: :deposit) }

    enum :role, {admin: 0, buyer: 1, stocker: 2}
    
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