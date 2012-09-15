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
    puts '>>> params:'
    puts params.inspect
    @place = Place.new({:name => params[:name], :ref => params[:ref]})
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
  
  # POST /geo
  def geo
    puts '>>> GEO WS'
    puts 'Lat Lng'
    puts params['latlng']
    
    if params.has_key?('latlng')
      places_url = URI.encode('https://maps.googleapis.com/maps/api/place/search/json?parameters?&location=' + params['latlng'] + '&rankby=distance&types=bar|restaurant|cafe|food|point_of_interest&language=en&sensor=true&key=AIzaSyDfvlLdmPj5jPMYy54KLcmkgvD68oFt5fM')
      puts places_url
      response = HTTParty.get(places_url)['results']
      
      puts 'response.each do |item|:'
      
      results = []
      
      response.each do |item|
        #puts item.inspect
        result_new = Hash.new
        
        item.each do |a|
          #puts a[0]
          if a[0] == "name" || a[0] == "formatted_address" || a[0] == "vicinity"
            #puts "key: " + a[0] + " val: " + a[1]
            result_new[a[0]] = a[1]
          end
        end
        
        results << result_new
      end
      
      puts 'results:'
      puts results.inspect
      
      payload = Hash.new
      
      payload[:success] = true
      payload[:results] = results
      
      render json: payload
      
    end
=begin
    $json_output = file_get_contents($results_places,0,null,null);
    $json_obj = json_decode($json_output, true);
    $results = array();
    foreach ($json_obj['results'] as $result) {
    	if (is_array($result)) {
    		$new_result = new stdClass();
    		foreach ($result as $key => $value) {
    			if ($key == "name" || $key == "formatted_address" || $key == "vicinity") {
    				//echo 'key: ' . $key . ' val: ' . $value . '<br>';
    				$new_result->$key = $value;
    			}
    		}
    		$results[] = $new_result;
    	}	
    }

    echo '{"success":true,"results":' . json_encode($results) . '}';
=end    
    
    
    
    
    
    
    #@place = Place.new
    #render json: @place
  end
end
