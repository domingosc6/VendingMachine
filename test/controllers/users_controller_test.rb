require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test 'should post deposit' do
    mingos = users(:mingos)
    old_deposit = mingos.deposit

    post login_url, params: {username: mingos.username, password: 'mingos123'}, as: :json
    assert_response :success
    token = JSON.parse(response.body)['token']

    deposit_to_do = 100
    expected_deposit = old_deposit + deposit_to_do
    post deposit_url, params: { deposit: deposit_to_do }, headers: { 'token': token }, as: :json
    assert_response :success

    new_deposit = JSON.parse(response.body)['user']['deposit']
    assert_equal(expected_deposit, new_deposit)
  end

  test 'should not post deposit' do
    mingos = users(:mingos)

    post login_url, params: {username: mingos.username, password: 'mingos123'}, as: :json
    assert_response :success
    token = JSON.parse(response.body)['token']

    deposit_to_do = 60
    post deposit_url, params: { deposit: deposit_to_do }, headers: { 'token': token }, as: :json
    assert_response :bad_request

    expected_error_message = "Deposit should be one coin of #{ApplicationHelper::CoinsToUse.to_sentence(last_word_connector: ' or ')}"
    error_message = JSON.parse(response.body)['errors'][0]['detail']
    assert_equal(expected_error_message, error_message)
  end

  test 'should create user then logout then login then show info' do
    user_json = { user: {username: 'Test', email: 'test@mail.com', role: 'buyer', deposit: 0, password: 'Test123'} }

    post users_url, params: user_json, as: :json
    assert_response :success

    delete logout_all_url, params: {username: user_json[:user][:username], password: user_json[:user][:password]}, as: :json
    assert_response :success

    post login_url, params: {username: user_json[:user][:username], password: user_json[:user][:password]}, as: :json
    assert_response :success
    token = JSON.parse(response.body)['token']

    get profile_url, headers: { 'token': token }, as: :json
    profile_json = JSON.parse(response.body)['user']

    assert_equal(user_json[:user][:username], profile_json['username'])
    assert_equal(user_json[:user][:email], profile_json['email'])
    assert_equal(user_json[:user][:role], profile_json['role'])
    assert_equal(user_json[:user][:deposit], profile_json['deposit'])

  end

  test 'should update user email' do
    mingos = users(:mingos)

    post login_url, params: {username: mingos.username, password: 'mingos123'}, as: :json
    assert_response :success
    token = JSON.parse(response.body)['token']

    expected_email = 'test_use_case@mail.com'
    put user_url, params: { email: expected_email }, headers: { 'token': token }, as: :json
    assert_response :success

    new_email = JSON.parse(response.body)['user']['email']

    assert_equal(expected_email, new_email)
  end

  test 'should not update user email' do
    mingos = users(:mingos)
    admin = users(:admin)

    post login_url, params: {username: mingos.username, password: 'mingos123'}, as: :json
    assert_response :success
    token = JSON.parse(response.body)['token']

    put user_url, params: { email: admin.email }, headers: { 'token': token }, as: :json
    assert_response :bad_request
    expected_error_message = 'Email has already been taken'
    error_message = JSON.parse(response.body)['errors'][0]['detail']

    assert_equal(expected_error_message, error_message)
  end

  test 'as admin should show info about users' do
    admin = users(:admin)

    post login_url, params: {username: admin.username, password: 'admin'}, as: :json
    assert_response :success
    token = JSON.parse(response.body)['token']

    get users_url, headers: { 'token': token }, as: :json
    assert_response :success

    users_json = JSON.parse(response.body)
    assert_equal(users.count, users_json.count)

  end

  test 'as normal user should not show info about users' do
    mingos = users(:mingos)

    post login_url, params: {username: mingos.username, password: 'mingos123'}, as: :json
    assert_response :success
    token = JSON.parse(response.body)['token']

    get users_url, headers: { 'token': token }, as: :json
    assert_response :unauthorized

    expected_error_message = 'You don\'t have the necessary role for this action.'
    error_message = JSON.parse(response.body)['errors'][0]['detail']

    assert_equal(expected_error_message, error_message)
  end

  test 'as admin should delete user' do
    admin = users(:admin)
    mingos = users(:mingos)
    user_to_delete = mingos.id

    post login_url, params: {username: admin.username, password: 'admin'}, as: :json
    assert_response :success
    token = JSON.parse(response.body)['token']

    delete "/users/#{user_to_delete}", headers: { 'token': token }, as: :json
    assert_response :success

    expected_message = "User with id #{user_to_delete} destroyed succesfully";
    message = JSON.parse(response.body)['message']
    assert_equal(expected_message, message)

  end
end
