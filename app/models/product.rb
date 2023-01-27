class Product < ApplicationRecord
    include CostValidation

    validates :name, presence: true
    validates_numericality_of :amount_available, greater_than_or_equal_to: 0
    validates_numericality_of :cost, greater_than_or_equal_to: 5
    validate -> { validate_multipleness(value: self.cost, multiple: 5, variable: :cost) }
    belongs_to :seller, foreign_key: :seller_id, class_name: 'User'

    def product_in_json(from_admin = false)
        return {product: {name: name, amount_available: amount_available, cost: cost, seller: seller.username, id: id}}
    end

end
