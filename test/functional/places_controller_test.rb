require 'test_helper'

class PlacesControllerTest < ActionController::TestCase
  setup do
    @place = places(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:places)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create place" do
    assert_difference('Place.count') do
      post :create, place: { location: @place.location, name: @place.name, ot_rid: @place.ot_rid }
    end

    assert_response 201
  end

  test "should show place" do
    get :show, id: @place
    assert_response :success
  end

  test "should update place" do
    put :update, id: @place, place: { location: @place.location, name: @place.name, ot_rid: @place.ot_rid }
    assert_response 204
  end

  test "should destroy place" do
    assert_difference('Place.count', -1) do
      delete :destroy, id: @place
    end

    assert_response 204
  end
end
