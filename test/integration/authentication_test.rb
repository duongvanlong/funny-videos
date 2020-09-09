require 'test_helper'

class AuthenticationTest < ActionDispatch::IntegrationTest

  test "redirect to login page" do
    get "/"
    assert_response :redirect
    assert_redirected_to "/users/sign_in"
  end

  test "redirect to login page and back to homepage with correct email and password" do
    get "/"
    assert_response :redirect
    assert_redirected_to "/users/sign_in"
    follow_redirect!
    post "/users/sign_in", params: {user: { email: "test1@funnyvideos.com", password: "password"}}
    assert_response :redirect
    assert_redirected_to "/"
  end

  test "redirect to login page and show error message with incorrect email" do
    get "/"
    # assert_response :success
    assert_response :redirect
    assert_redirected_to "/users/sign_in"
    follow_redirect!
    post "/users/sign_in", params: {user: { email: "invalid@funnyvideos.com", password: "password"}}
    assert_select "p.alert", "Invalid Email or password."
  end

  test "redirect to login page and show error message with incorrect password" do
    get "/"
    assert_response :redirect
    assert_redirected_to "/users/sign_in"
    follow_redirect!
    post "/users/sign_in", params: {user: { email: "test1@funnyvideos.com", password: "invalid"}}
    assert_select "p.alert", "Invalid Email or password."
  end

  test "not redirect if user login already" do
    get "/"
    assert_response :redirect
    assert_redirected_to "/users/sign_in"
    follow_redirect!
    post "/users/sign_in", params: {user: { email: "test1@funnyvideos.com", password: "password"}}
    get "/"
    assert_response :success
  end
end
