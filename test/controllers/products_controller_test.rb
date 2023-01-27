require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  include ApplicationHelper
  test "should buy product" do
    mingos = users(:mingos)
    mars = products(:mars)

    old_deposit = mingos.deposit
    old_amount = mars.amount_available
    amount = 1
    expected_amount = old_amount - amount
    product_id = mars.id
    
    post login_url, params: {username: mingos.username, password: 'mingos123'}, as: :json
    assert_response :success
    token = JSON.parse(response.body)['token']

    post buy_url, params: {amount: amount, product_id: product_id}, headers: { 'token': token }, as: :json
    assert_response :bad_request

    error_message = JSON.parse(response.body)['errors'][0]['detail']
    expected_error_message = 'The product value is too high for your purchase.'
    assert_equal(expected_error_message, error_message)
    
    deposit_to_do = 100
    expected_deposit = old_deposit + deposit_to_do
    post deposit_url, params: { deposit: deposit_to_do }, headers: { 'token': token }, as: :json
    assert_response :success

    new_deposit = JSON.parse(response.body)['user']['deposit']
    assert_equal(expected_deposit, new_deposit)

    post buy_url, params: {amount: amount, product_id: product_id}, headers: { 'token': token }, as: :json
    assert_response :success

    expected_change_value = new_deposit - mars.cost
    expected_change_in_coins = get_change_in_coins(expected_change_value)
    change_in_coins = JSON.parse(response.body)['change']
    change_value = change_in_coins.sum

    assert_equal(expected_change_value, change_value)
    assert_equal(expected_change_in_coins, change_in_coins)

    get product_url(product_id)
    assert_response :success
    amount_from_product = JSON.parse(response.body)['product']['amount_available']
    assert_equal(expected_amount, amount_from_product)
  end

end
