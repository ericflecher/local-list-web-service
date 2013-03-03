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
    # puts '>>> index'
    # puts '>>> params[:archived]'
    # puts params[:archived]

    # # Old index, gets everyones saved places, including archived
    # if params.has_key?(:archived) && params[:archived] == 'true'
    #   puts '>>> archived is true'
    #   @places = SavedPlace.all
    # else
    #   puts '>>> archived is not true, display only archived != true'
    #   @places = SavedPlace.where('archived != ? OR archived IS NULL', true)
    # end
    
    if params.has_key?(:user_id) && params[:user_id]
      @places = SavedPlace.find_all_by_user_id(params[:user_id])
    else
      @places = nil
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
end
