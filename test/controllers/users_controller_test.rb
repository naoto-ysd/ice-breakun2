require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get show" do
    get user_url(users(:one))
    assert_response :success
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should get create" do
    post users_url, params: { user: { name: "Test User", email: "test@example.com", slack_id: "@test" } }
    assert_response :redirect
  end

  test "should get edit" do
    get edit_user_url(users(:one))
    assert_response :success
  end

  test "should get update" do
    patch user_url(users(:one)), params: { user: { name: "Updated User" } }
    assert_response :redirect
  end

  test "should get destroy" do
    delete user_url(users(:one))
    assert_response :redirect
  end
end
