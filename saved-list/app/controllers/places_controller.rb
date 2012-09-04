class PlacesController < ApplicationController
  # GET /places
  # GET /places.json
  def index
    @places = Place.all

    render json: @places
  end

  # GET /places/1
  # GET /places/1.json
  def show
    @place = Place.find(params[:id])

    render json: @place
  end

  # GET /places/new
  # GET /places/new.json
  def new
    @place = Place.new

    render json: @place
  end

  # POST /places
  # POST /places.json
  def create
    @place = Place.new(params[:place])

    if @place.save
      render json: @place, status: :created, location: @place
    else
      render json: @place.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /places/1
  # PATCH/PUT /places/1.json
  def update
    @place = Place.find(params[:id])

    if @place.update_attributes(params[:place])
      head :no_content
    else
      render json: @place.errors, status: :unprocessable_entity
    end
  end

  # DELETE /places/1
  # DELETE /places/1.json
  def destroy
    @place = Place.find(params[:id])
    @place.destroy

    head :no_content
  end
end
