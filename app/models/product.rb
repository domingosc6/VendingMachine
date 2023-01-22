class Product < ApplicationRecord
    validate :cost_is_multiple_of_five
    validates_numericality_of :amount, greater_than: 0
    validates_numericality_of :cost, greater_than: 5
    
    private

    def cost_is_multiple_of_five
        unless (cost % 5) == 0
            errors.add(:cost, "must be multiple of 5 cents")
        end
    end

end
