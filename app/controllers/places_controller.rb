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
  
  
  require 'oauth'
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
      
      consumer_key = 'yQOQxtNtpLyPOtPVeOFiuQ'
      consumer_secret = 'wbGrz176uFBeQZazJx_OkYkAng8'
      token = '1St_-kOKX8rKJYf33hO-MB0qdVKJJcQm'
      token_secret = 'X5l9MQ9IBRXrr5eb2jCUU6r-GZM'
      
      api_host = 'api.yelp.com'
      
      consumer = OAuth::Consumer.new(consumer_key, consumer_secret, {:site => "http://#{api_host}"})
      access_token = OAuth::AccessToken.new(consumer, token, token_secret)
      
      path = "/v2/search?sort=1&ll=" + params['latlng'] + "&limit=10&category_filter=restaurants"
      
      response = JSON.parse(access_token.get(path).body)["businesses"]
      
      # ap response
      ap response[0]
      
      # # Google Places Nearby Search API
      # places_url = URI.encode('https://maps.googleapis.com/maps/api/place/search/json?parameters?&location=' + params['latlng'] + '&rankby=distance&types=bar|restaurant|cafe|food&language=en&sensor=true&key=AIzaSyDfvlLdmPj5jPMYy54KLcmkgvD68oFt5fM')
      # #puts places_url
      # response = HTTParty.get(places_url)['results']
      
      results = []
      
      response.each do |item|
        # ap item
        
        result = Hash.new
        
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
        
        # # CANT SAVE TO DB BECAUSE YELP DATA
        # Create new place if it does not exist
        # place = Place.find_by_uid(result["uid"])
        # if !place
        #   puts '>>> place not in DB'
        #   place = Place.new
        #   
        #   ### !!! NOTE: taking uid, location, city out since its not used yet (Open API potentially)
        #   
        #   # place.uid = result["uid"]
        #   place.name = result["name"]
        #   # place.location = result["vicinity"]
        #   
        #   ap result
        #   # ap place.location
        #   ap place
        #   
        #   # # Taking city and location out, not used currently
        #   # city_const = ", "
        #   # 
        #   # index = place.location.rindex(city_const)
        #   # if index
        #   #   place.city = place.location.slice(index + city_const.length..place.location.length)
        #   # else
        #   #   place.city = place.location
        #   # end
        #   
        #   # Save the place to DB
        #   place.save
        #   
        #   # # check if exists in OT
        #   # place.ot_rid = ot_rid(place)
        #   # 
        #   # puts '>>> ot_rid:'
        #   # ap place.ot_rid
        # end
        
        # # if exists in OT then send data to front end
        # result["ot"] = place.ot_rid
        
        results << result
      end
      
      # puts '>>> results:'
      # puts results
      # ap results
      
      payload = Hash.new
      payload[:success] = !results.empty?
      
      payload[:results] = results
      
      render json: payload
    end
  end
  
  
  
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
  
  
  
  require 'nokogiri'
  
  # GET /otp (TEMPORARY)
  # POST /otp
  # POST /otp.json
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
  
  
  
  # POST /otp
  # POST /otp.json
  def yelp
    
    if params.has_key?('reference')
      # Call Google Places to get phone number
      places_url = URI.encode('https://maps.googleapis.com/maps/api/place/details/json?reference=' + params['reference'] + '&sensor=true&key=AIzaSyDfvlLdmPj5jPMYy54KLcmkgvD68oFt5fM')
      places_response = HTTParty.get(places_url)['result']
      
      # puts '>>> google details response'
      # ap response
      
      phone_number = places_response['formatted_phone_number']
      phone_digits = places_response['international_phone_number'].delete("+ ()-")
      
      categories = []
      neighborhoods = []
      
      api_host = 'api.yelp.com'
      ywsid = 'QyGURgxJPFWajTpsNPJeJg'
      
      yelp_url = "http://#{api_host}" + '/phone_search?phone=' + phone_digits + '&ywsid=' + ywsid
      
      # HTTParty hard the above path
      yelp_response = HTTParty.get(yelp_url, :format => :json)["businesses"][0]
      
      # puts '>>>> yelp response'
      # ap yelp_response
      
      if yelp_response
        # puts '>>> categories'
        # ap yelp_response["categories"]
        
        yelp_response["categories"].each do |category|
          categories << category["name"]
        end
        
        yelp_response["neighborhoods"].each do |neighborhood|
          neighborhoods << neighborhood["name"]
        end
        
        address = yelp_response["address1"]
        
        results = Hash.new
        results["address"] = address
        results["phone"] = phone_number
        results["categories"] = categories
        results["neighborhoods"] = neighborhoods
        
        response = Hash.new
        response[:success] = true
        response[:results] = results
      else
        response = Hash.new
        response[:success] = false
      end
      
      render json: response
    end
  end
  
  
end
