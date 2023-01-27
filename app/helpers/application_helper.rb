module ApplicationHelper
    CoinsToUse = [5, 10, 20, 50, 100]
    UnauthorizedAccess = 'You don\'t have the necessary role for this action.'

    def get_change_in_coins(change)
        coins = []
        if change.positive?
            change_aux = change
            while change_aux.positive?
                CoinsToUse.reverse.each do |coin|
                    unless (change_aux - coin).negative?
                        coins << coin
                        change_aux -= coin
                        break
                    end
                end
            end
        end
        coins
    end
end
