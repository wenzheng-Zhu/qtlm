require 'test_helper'

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "should get make" do
    get welcome_make_url
    assert_response :success
  end

end
