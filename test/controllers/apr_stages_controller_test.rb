require 'test_helper'

class AprStagesControllerTest < ActionController::TestCase
  setup do
    @apr_stage = apr_stages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:apr_stages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create apr_stage" do
    assert_difference('AprStage.count') do
      post :create, apr_stage: { apr: @apr_stage.apr, begin_date: @apr_stage.begin_date, begin_money: @apr_stage.begin_money, end_date: @apr_stage.end_date, end_money: @apr_stage.end_money, financing_id: @apr_stage.financing_id }
    end

    assert_redirected_to apr_stage_path(assigns(:apr_stage))
  end

  test "should show apr_stage" do
    get :show, id: @apr_stage
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @apr_stage
    assert_response :success
  end

  test "should update apr_stage" do
    patch :update, id: @apr_stage, apr_stage: { apr: @apr_stage.apr, begin_date: @apr_stage.begin_date, begin_money: @apr_stage.begin_money, end_date: @apr_stage.end_date, end_money: @apr_stage.end_money, financing_id: @apr_stage.financing_id }
    assert_redirected_to apr_stage_path(assigns(:apr_stage))
  end

  test "should destroy apr_stage" do
    assert_difference('AprStage.count', -1) do
      delete :destroy, id: @apr_stage
    end

    assert_redirected_to apr_stages_path
  end
end
