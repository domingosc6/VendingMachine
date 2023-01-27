require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
    test 'should login then logout' do
        mingos = users(:mingos)
    
        post login_url, params: {username: mingos.username, password: 'mingos123'}, as: :json
        assert_response :success

        delete logout_all_url, params: {username: mingos.username, password: 'mingos123'}, as: :json
        assert_response :success
        expected_message = 'Logout successful!'
        message = JSON.parse(response.body)['message']

        assert_equal(expected_message, message)
    end

    test 'should not login' do
        mingos = users(:mingos)
    
        post login_url, params: {username: mingos.username, password: 'error'}, as: :json
        assert_response :unauthorized

        expected_error_message = 'Incorrect password, please try again.'
        error_message = JSON.parse(response.body)['errors'][0]['detail']
        assert_equal(expected_error_message, error_message)
    end


end