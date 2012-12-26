class PlacesController < ApplicationController
  # GET /places
  # GET /places.json
  def index
    places = Place.all

    render json: places
  end

  # GET /places/1
  # GET /places/1.json
  def show
    place = Place.find(params[:id])

    render json: place
  end

  # GET /places/new
  # GET /places/new.json
  def new
    place = Place.new

    render json: place
  end

  # POST /places
  # POST /places.json
  def create
    place = Place.new(params[:place])

    if place.save
      render json: place, status: :created, location: place
    else
      render json: place.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /places/1
  # PATCH/PUT /places/1.json
  def update
    place = Place.find(params[:id])

    if place.update_attributes(params[:place])
      head :no_content
    else
      render json: place.errors, status: :unprocessable_entity
    end
  end

  # DELETE /places/1
  # DELETE /places/1.json
  def destroy
    place = Place.find(params[:id])
    place.destroy

    head :no_content
  end
  
  
  
  require 'nokogiri'
  require 'open-uri'
  require 'httparty'
  require 'ap'
  
  # POST /places/get
  # POST /places/get.json
  def get
    puts '>>> GEO WS'
    puts 'Lat Lng'
    ap params['latlng']
    
    if params.has_key?('latlng')
      places_url = URI.encode('https://maps.googleapis.com/maps/api/place/search/json?parameters?&location=' + params['latlng'] + '&rankby=distance&types=bar|restaurant|cafe|food&language=en&sensor=true&key=AIzaSyDfvlLdmPj5jPMYy54KLcmkgvD68oFt5fM')
      #puts places_url
      response = HTTParty.get(places_url)['results']
      
      #puts 'response.each do |item|:'
      
      results = []
      
      response.each do |item|
        # ap item
        
        result_new = Hash.new
        
        item.each do |attrib|
          # puts attrib[0]
          if attrib[0] == "name" # || attrib[0] == "formatted_address" || attrib[0] == "vicinity"
            # puts "key: " + attrib[0] + " val: " + attrib[1]
            result_new[attrib[0]] = attrib[1]
          elsif attrib[0] == "id"
            result_new["uid"] = attrib[1]
          end
        end
        
        # Create new place if it does not exist
        place = Place.find_by_uid(result_new["uid"])
        
        if !place
          puts '>>> place not in DB'
          place = Place.new
          place.uid = result_new["uid"]
          place.name = result_new["name"]
          # may need to change vicinity to formatted_address, or account for both?
          place.location = result_new["vicinity"]
          # loc.slice(loc.index(", ")+", ".length..loc.length)
          
          city_const = ", "
          
          index = place.location.rindex(city_const)
          if index
            place.city = place.location.slice(index + city_const.length..place.location.length)
          else
            place.city = place.location
          end
          
          # Save the place to DB
          place.save
          
          # # check if exists in OT
          # place.ot_rid = ot_rid(place)
          # 
          # puts '>>> ot_rid:'
          # ap place.ot_rid
        end
        
        # if exists in OT then send data to front end
        result_new["ot"] = place.ot_rid
        
        results << result_new
      end
      
      puts '>>> results:'
      # puts results
      # ap results
      
      payload = Hash.new
      
      payload[:success] = true
      payload[:results] = results
      
      render json: payload
    end
  end
  
  
  
  # GET /ot_exists (TEMPORARY)
  # POST /ot_exists
  # POST /ot_exists.json
  def ot_rid (place)
    # check for params
    puts ">>> PLACE:"
    ap place
    
    if place.name && place.location
      # Get Restaurant ID
      
      # constants for google search url
      base_url = 'https://www.googleapis.com/customsearch/v1'
      api_key = 'AIzaSyDfvlLdmPj5jPMYy54KLcmkgvD68oFt5fM'
      custom_search_key = '016942613514382480740:iokbti_buou'
      
      # vars for google search url
      
      # query is restaurant and city
      q = place.name + " " + place.city
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
        
        # puts '>>> index of rid'
        # ap index
        
        rid = nil
        
        if index
          # get the rid
          rid = ot_url.slice(index+rid_const.length..ot_url.length)
        end
        
        puts '>>> ot_url:'
        ap ot_url
        
        puts '>>> rid:'
        ap rid
        
        # return OT RID
        return rid
      end
    end
    
    return false
  end
  
  def ot_parser
    # check for params
    puts ">>> PARAMS:"
    ap params
    
    # Init times array
    response = {}
    # puts '>>> has params check here'
    if params.has_key?(:uid) && params.has_key?(:s) && params.has_key?(:d) && params.has_key?(:t)
      place = Place.find_by_uid(params[:uid])
    end
    
    puts '>>> place:'
    ap place
    
    # See if exists in OT / get Restuarant ID
    if place && place.ot_rid.nil?
      puts '>>> See if exists in OT'
      place.ot_rid = ot_rid(place)
      place.save!
    end
    
    if place && place.ot_rid && place.ot_rid != "f"
      # >>> Step 2 - get Times
      # http://m.opentable.com/search/results?Date=2012-12-19T00%3A00%3A00&TimeInvariantCulture=0001-01-01T19%3A30%3A00&PartySize=2&RestaurantID=47
      base_url = 'http://m.opentable.com'
      base_search_url = base_url + '/search/results'
      party_size = params[:s]
      date = params[:d]
      time = params[:t]
      query = '?' + 'Date=' + (CGI::escape date) + '&TimeInvariantCulture=' + (CGI::escape time) + '&PartySize=' + (CGI::escape party_size) + '&RestaurantID=' + place.ot_rid
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
    
    puts '>>> response:'
    ap response
    
    render json: response
  end
  
  
end
