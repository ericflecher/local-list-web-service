class SavedPlacesController < ApplicationController
  
  def places_create_update
    #puts '>>>>> places_create_update'
    puts '>>>>> email'
    puts params[:email]
    
    if params[:email]
      user_id = User.find_or_create_by_email(params[:email]).id
      
      { :user_id => user_id, :yelp_id => params[:yelp_id], :come_back => params[:come_back] }
    end
  end
  
  # GET /places
  # GET /places.json
  def index
    if params.has_key?(:user_id) && params[:user_id]
      @places = SavedPlace.find_all_by_user_id(params[:user_id])
      
      results = []
      
      @places.each do |place|
        # Call Yelp v2 business api
        ap place["yelp_id"]
        result = yelp_business(place["yelp_id"])
        result["id"] = place.id
        result["come_back"] = place.come_back
        
        results << result
      end
      
    else
      results = nil
    end
    
    render json: results
  end

  # GET /places/1
  # GET /places/1.json
  def show
    @place = SavedPlace.find(params[:id])

    render json: @place
  end

  # GET /places/new
  # GET /places/new.json
  def new
    @place = SavedPlace.new

    render json: @place
  end

  # POST /places
  # POST /places.json
  def create
    puts '>>> params:'
    puts params.inspect
    
    params[:come_back] = false
    
    @place = SavedPlace.new(places_create_update)
    puts '>>> place:'
    puts @place.inspect

    if @place.save
      render json: @place, status: :created, location: @place
    else
      render json: @place.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /places/1
  # PATCH/PUT /places/1.json
  def update
    @place = SavedPlace.find(params[:id])

    if @place.update_attributes(places_create_update)
      head :no_content
    else
      render json: @place.errors, status: :unprocessable_entity
    end
  end

  # DELETE /places/1
  # DELETE /places/1.json
  def destroy
    puts '>>> index'
    @place = SavedPlace.find(params[:id])
    
    @place.destroy

    head :no_content
  end
  
  require 'oauth'
  
  def yelp_business(yelp_id)
    consumer_key = 'yQOQxtNtpLyPOtPVeOFiuQ'
    consumer_secret = 'wbGrz176uFBeQZazJx_OkYkAng8'
    token = '1St_-kOKX8rKJYf33hO-MB0qdVKJJcQm'
    token_secret = 'X5l9MQ9IBRXrr5eb2jCUU6r-GZM'
    
    api_host = 'api.yelp.com'
    
    consumer = OAuth::Consumer.new(consumer_key, consumer_secret, {:site => "http://#{api_host}"})
    access_token = OAuth::AccessToken.new(consumer, token, token_secret)
    
    path = "/v2/business/" + yelp_id
    
    item = JSON.parse(access_token.get(path).body)
    
    result = Hash.new
    result["yelp_id"] = item["id"]
    result["name"] = item["name"]
    result["address"] = item["location"]["address"][0]
    result["phone"] = item["display_phone"]
    result["categories"] = []
    
    item["categories"].each do |category|
      result["categories"] << category[0]
    end
    
    result["neighborhoods"] = []
    
    item["location"]["neighborhoods"].each do |neighborhood|
      result["neighborhoods"] << neighborhood
    end
    
    result
  end
end
