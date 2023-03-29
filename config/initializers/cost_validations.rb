module CostValidation
    def validate_multipleness(parameters)
        unless (parameters[:value] % parameters[:multiple]) == 0
            errors.add(parameters[:variable], "must be multiple of 5 cents")
        end
    end
end