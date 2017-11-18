require 'test_helper'

class OrientationsControllerTest < ActionController::TestCase
  setup do
    @orientation = orientations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:orientations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create orientation" do
    assert_difference('Orientation.count') do
      post :create, orientation: { name: @orientation.name }
    end

    assert_redirected_to orientation_path(assigns(:orientation))
  end

  test "should show orientation" do
    get :show, id: @orientation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @orientation
    assert_response :success
  end

  test "should update orientation" do
    patch :update, id: @orientation, orientation: { name: @orientation.name }
    assert_redirected_to orientation_path(assigns(:orientation))
  end

  test "should destroy orientation" do
    assert_difference('Orientation.count', -1) do
      delete :destroy, id: @orientation
    end

    assert_redirected_to orientations_path
  end
end
