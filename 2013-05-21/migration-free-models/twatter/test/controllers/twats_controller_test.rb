require 'test_helper'

class TwatsControllerTest < ActionController::TestCase
  setup do
    @twat = twats(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:twats)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create twat" do
    assert_difference('Twat.count') do
      post :create, twat: { author: @twat.author, status: @twat.status }
    end

    assert_redirected_to twat_path(assigns(:twat))
  end

  test "should show twat" do
    get :show, id: @twat
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @twat
    assert_response :success
  end

  test "should update twat" do
    patch :update, id: @twat, twat: { author: @twat.author, status: @twat.status }
    assert_redirected_to twat_path(assigns(:twat))
  end

  test "should destroy twat" do
    assert_difference('Twat.count', -1) do
      delete :destroy, id: @twat
    end

    assert_redirected_to twats_path
  end
end
