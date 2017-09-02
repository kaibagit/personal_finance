require 'test_helper'

class FinancingItemsControllerTest < ActionController::TestCase
  setup do
    @financing_item = financing_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:financing_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create financing_item" do
    assert_difference('FinancingItem.count') do
      post :create, financing_item: { financing_id: @financing_item.financing_id, interested_at: @financing_item.interested_at, money_cent: @financing_item.money_cent, paid_at: @financing_item.paid_at }
    end

    assert_redirected_to financing_item_path(assigns(:financing_item))
  end

  test "should show financing_item" do
    get :show, id: @financing_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @financing_item
    assert_response :success
  end

  test "should update financing_item" do
    patch :update, id: @financing_item, financing_item: { financing_id: @financing_item.financing_id, interested_at: @financing_item.interested_at, money_cent: @financing_item.money_cent, paid_at: @financing_item.paid_at }
    assert_redirected_to financing_item_path(assigns(:financing_item))
  end

  test "should destroy financing_item" do
    assert_difference('FinancingItem.count', -1) do
      delete :destroy, id: @financing_item
    end

    assert_redirected_to financing_items_path
  end
end
