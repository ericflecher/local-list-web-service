class PlacesController < ApplicationController
  
  def places_create_update
    #puts '>>>>> places_create_update'
    puts '>>>>> email'
    puts params[:email]
    
    if params[:email]
      puts '>>>>> find user (or create) by email'
      user = User.find_or_create_by_email(params[:email])
      puts '>>>>> user'
      puts user.inspect
      
      user_id = user.id
      
      puts '>>>>> user_id'
      puts user_id
      
      {:user_id => user_id, :uid => params[:uid], :name => params[:name], :ref => params[:ref], :saved => params[:saved], :come_back => params[:come_back], :archived => params[:archived]}
    end
  end
  
  # GET /places
  # GET /places.json
  def index
    puts '>>> index'
    puts '>>> params[:archived]'
    puts params[:archived]
    
    if params.has_key?(:archived) && params[:archived] == true
      puts '>>> archived is true'
      @places = Place.all
    else
      @places = Place.where('archived != ?', true)
    end
    
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
    puts '>>> params:'
    puts params.inspect
    @place = Place.new(places_create_update)
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
    @place = Place.find(params[:id])

    #if @place.update_attributes(params[:place])
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
    @place = Place.find(params[:id])
    
    puts '>>> params[:permanent]'
    puts params[:permanent]
    
    if params.has_key?(:permanent) && params[:permanent] == true
      puts '>>> permanent is true'
      @place.destroy
    else
      @place.archived = true
      @place.save
    end

    head :no_content
  end
  
  # POST /geo
  def geo
    puts '>>> GEO WS'
    #puts 'Lat Lng'
    #puts params['latlng']
    
    if params.has_key?('latlng')
      places_url = URI.encode('https://maps.googleapis.com/maps/api/place/search/json?parameters?&location=' + params['latlng'] + '&rankby=distance&types=bar|restaurant|cafe|food&language=en&sensor=true&key=AIzaSyDfvlLdmPj5jPMYy54KLcmkgvD68oFt5fM')
      #puts places_url
      response = HTTParty.get(places_url)['results']
      
      #puts 'response.each do |item|:'
      
      results = []
      
      response.each do |item|
        #puts item.inspect
        result_new = Hash.new
        
        item.each do |a|
          #puts a[0]
          if a[0] == "name" || a[0] == "formatted_address" || a[0] == "vicinity"
            #puts "key: " + a[0] + " val: " + a[1]
            result_new[a[0]] = a[1]
          elsif a[0] == "id"
            result_new["uid"] = a[1]
          end
        end
        
        results << result_new
      end
      
      #puts 'results:'
      #puts results.inspect
      
      payload = Hash.new
      
      payload[:success] = true
      payload[:results] = results
      
      render json: payload      
    end
  end
end
