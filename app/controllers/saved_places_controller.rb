class SavedPlacesController < ApplicationController
  
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
      
      # if !params.has_key?(:archived) || !params[:archived]
        # archived = false
      # end
      
      {:user_id => user_id, :uid => params[:uid], :name => params[:name], :ref => params[:ref], :saved => params[:saved], :come_back => params[:come_back], :archived => false}
    end
  end
  
  # GET /places
  # GET /places.json
  def index
    puts '>>> index'
    puts '>>> params[:archived]'
    puts params[:archived]
    
    if params.has_key?(:archived) && params[:archived] == 'true'
      puts '>>> archived is true'
      @places = SavedPlace.all
    else
      puts '>>> archived is not true, display only archived != true'
      @places = SavedPlace.where('archived != ? OR archived IS NULL', true)
    end
    
    render json: @places
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
    @place = SavedPlace.find(params[:id])
    
    puts '>>> params[:permanent]'
    puts params[:permanent]
    
    if params.has_key?(:permanent) && params[:permanent] == 'true'
      puts '>>> permanent is true'
      @place.destroy
    else
      @place.archived = true
      @place.save
    end

    head :no_content
  end
  
  # POST /geo
  # GET /geo
  # *** ? /geo
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
  
  require 'nokogiri'
  require 'open-uri'
  require 'httparty'
  require 'ap'
  # GET /otp (TEMPORARY)
  # POST /otp
  # POST /otp.json
  def ot_parser
    
    # check for params
    puts ">>> PARAMS:"
    puts params
    
    # Init times array
    response = {}
    puts '>>> has params check here'
    if params.has_key?(:r) && params.has_key?(:c) && params.has_key?(:s) && params.has_key?(:d)
      # >>> Step 1 - get Restaurant ID
      
      # constants for google search url
      base_url = 'https://www.googleapis.com/customsearch/v1'
      api_key = 'AIzaSyDfvlLdmPj5jPMYy54KLcmkgvD68oFt5fM'
      custom_search_key = '016942613514382480740:iokbti_buou'
      
      # vars for google search url
      
      # query is restaurant and city
      q = params[:r] + " " + params[:c]
      # q = 'rise sushi chicago'
      # q = 'shaws chicago'
      type = 'json'
      # number of results
      num = '10'
      
      query = '?key=' + api_key + '&cx=' + custom_search_key + '&q=' + (CGI::escape q) + '&alt=' + type + '&num=' + num
      
      puts '>>> query'
      ap query
      
      url = base_url + query
      
      puts '>>> google search url:'
      puts url
      
      # get GET result from google search results
      results = HTTParty.get(url).parsed_response["items"]
      
      puts '>>> results:'
      # ap results
      
      if results
        
        rid_const = 'rid='
        
        ot_url = results[0]["link"]
        
        results.each do |result|
          link = result["link"]
          ap link
          
          if link.index(rid_const)
            ot_url = link
            break
          end
        end
        
        # Check if the link has rid in it
        index = ot_url.index(rid_const)
        
        puts '>>> index of rid'
        ap index
        rid = nil
        if index
          # get the rid
          rid = ot_url.slice(index+rid_const.length..ot_url.length)
          puts '>>> rid'
          ap rid
        end
        
        # Test incase rid is not the last param
        # ot_url += "&test=blah&r=fake"
        
        puts '>>> ot_url:'
        ap ot_url
        
        puts '>>> rid:'
        ap rid
        
        # >>> Step 2 - get Times
        
        # http://m.opentable.com/search/results?Date=2012-12-19T13%3A35%3A00&PartySize=2&RestaurantID=47
        base_url = 'http://m.opentable.com'
        base_search_url = base_url + '/search/results'
        party_size = params[:s]
        # date_time = '2013-01-11T20:00:00'
        date = params[:d]
        time = params[:t]
        query = '?' + 'Date=' + (CGI::escape date) + '&TimeInvariantCulture=' + (CGI::escape time) + '&PartySize=' + (CGI::escape party_size) + '&RestaurantID=' + rid
        url = base_search_url + query
        
        puts '>>> open table url:'
        ap url
        
        # Get a Nokogiri::HTML::Document for the page we’re interested in...
        doc = Nokogiri::HTML(open(url))
        
        # times results array
        times = []
        
        # Search for nodes by css
        doc.css('ul#ulSlots li.ti a').each do |link|
        # doc.css('#ulSlots li a').each do |link|
          time = {}
          time["url"] = base_url + link['href']
          time["time"] = link.content.strip
        
          times << time
        end
        
        if times.empty?
          response[:error] = { :exists => "true", :error => "true", :url => url }
        else
          response[:error] = { :exists => "true", :error => "false", :url => url }
          response[:times] = times
        end
      else
        response[:error] = { :exists => "false" }
      end
    end
    
    # puts '>>> response:'
    puts response.inspect
    
    render json: response
  end
end
