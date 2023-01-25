class Product < ApplicationRecord
    include CostValidation

    validate -> { validate_multipleness(value: self.cost, multiple: 5, variable: :cost) }
    validates_numericality_of :amount_available, greater_than_or_equal_to: 0
    validates_numericality_of :cost, greater_than_or_equal_to: 5
    belongs_to :user, foreign_key: :seller_id, as: :seller

end
