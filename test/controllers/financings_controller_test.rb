require 'test_helper'

class FinancingsControllerTest < ActionController::TestCase
  setup do
    @financing = financings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:financings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create financing" do
    assert_difference('Financing.count') do
      post :create, financing: { act_antedated: @financing.act_antedated, act_earning: @financing.act_earning, act_rate: @financing.act_rate, channel_id: @financing.channel_id, exp_antedated: @financing.exp_antedated, exp_earning: @financing.exp_earning, exp_rate: @financing.exp_rate, money_cent: @financing.money_cent, name: @financing.name, paid_at: @financing.paid_at, status: @financing.status }
    end

    assert_redirected_to financing_path(assigns(:financing))
  end

  test "should show financing" do
    get :show, id: @financing
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @financing
    assert_response :success
  end

  test "should update financing" do
    patch :update, id: @financing, financing: { act_antedated: @financing.act_antedated, act_earning: @financing.act_earning, act_rate: @financing.act_rate, channel_id: @financing.channel_id, exp_antedated: @financing.exp_antedated, exp_earning: @financing.exp_earning, exp_rate: @financing.exp_rate, money_cent: @financing.money_cent, name: @financing.name, paid_at: @financing.paid_at, status: @financing.status }
    assert_redirected_to financing_path(assigns(:financing))
  end

  test "should destroy financing" do
    assert_difference('Financing.count', -1) do
      delete :destroy, id: @financing
    end

    assert_redirected_to financings_path
  end
end
