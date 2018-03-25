require 'test_helper'

class GdpsControllerTest < ActionController::TestCase
  setup do
    @gdp = gdps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:gdps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create gdp" do
    assert_difference('Gdp.count') do
      post :create, gdp: { m0: @gdp.m0, m0_chain_growth: @gdp.m0_chain_growth, m0_yoy_growth: @gdp.m0_yoy_growth, m1: @gdp.m1, m1_yoy_growth: @gdp.m1_yoy_growth, m2: @gdp.m2, m2_chain_growth: @gdp.m2_chain_growth, m2_yoy_growth: @gdp.m2_yoy_growth, month: @gdp.month }
    end

    assert_redirected_to gdp_path(assigns(:gdp))
  end

  test "should show gdp" do
    get :show, id: @gdp
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @gdp
    assert_response :success
  end

  test "should update gdp" do
    patch :update, id: @gdp, gdp: { m0: @gdp.m0, m0_chain_growth: @gdp.m0_chain_growth, m0_yoy_growth: @gdp.m0_yoy_growth, m1: @gdp.m1, m1_yoy_growth: @gdp.m1_yoy_growth, m2: @gdp.m2, m2_chain_growth: @gdp.m2_chain_growth, m2_yoy_growth: @gdp.m2_yoy_growth, month: @gdp.month }
    assert_redirected_to gdp_path(assigns(:gdp))
  end

  test "should destroy gdp" do
    assert_difference('Gdp.count', -1) do
      delete :destroy, id: @gdp
    end

    assert_redirected_to gdps_path
  end
end
