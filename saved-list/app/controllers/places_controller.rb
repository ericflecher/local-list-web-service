class PlacesController < ApplicationController
  
  def set_cors_headers
    response.headers['Access-Control-Allow-Origin'] == '*'
    response.headers['Access-Control-Allow-Methods'] == 'POST, GET, PUT, DELETE, OPTIONS, HEAD'
    response.headers['Access-Control-Allow-Credentials'] == 'true'
    response.headers['Access-Control-Allow-Headers'] == 'X-PINGOTHER'
    response.headers['Access-Control-Max-Age'] == '86400' # 24 hours
    puts '>>>> CORS HEADERS SET'
    puts response.headers.inspect
  end
  
  # GET /places
  # GET /places.json
  def index
    @places = Place.all
    
    set_cors_headers
    render json: @places
  end

  # GET /places/1
  # GET /places/1.json
  def show
    @place = Place.find(params[:id])

    set_cors_headers
    render json: @place
  end

  # GET /places/new
  # GET /places/new.json
  def new
    @place = Place.new

    set_cors_headers
    render json: @place
  end

  # POST /places
  # POST /places.json
  def create
    @place = Place.new(params[:place])

    set_cors_headers
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

    set_cors_headers
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

    set_cors_headers
    head :no_content
  end
end
