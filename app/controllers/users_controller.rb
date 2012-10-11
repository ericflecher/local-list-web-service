class UsersController < ApplicationController
    
  # GET /users
  # GET /users.json
  def index
    @users = User.all
    
    render json: @users
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    render json: @user
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    render json: @user
  end

  # POST /users
  # POST /users.json
  def create
    puts '>>> params:'
    puts params.inspect
    @user = User.new(params[:user])
    puts '>>> User:'
    puts @user.inspect

    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      head :no_content
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    head :no_content
  end
  
  # POST /users/new_unique_user
  # POST /users/new_unique_user.json
  def new_unique_user
    puts '>>> params:'
    puts params.inspect
    user = User.find_or_initialize_by_email(params[:user][:email])
    puts '>>> created?'
    puts user.new_record?

    if user.new_record?
      created = true
      
      #use_password default to false
      user.use_password = false
      
      if user.save
        success = true
      else
        success = false
      end
    else
      created = false
      success = true
    end
    
    response = { :success => success, :created => created }
    
    puts '>>> User:'
    puts user.inspect
    puts '>>> response'
    puts response.inspect
    
    render json: response
  end
  
  # POST /login
  # POST /login.json
  def login
    user = User.authenticate(params[:email], params[:password])
    if user
      response = { :success => true, :user_id => user.id }
    else
      response = { :success => false, :user_id => nil }
    end
    
    render json: response
  end
  
  # POST /users/setusepassword
  # POST /users/setusepassword.json
  def setusepassword
    user = User.find_by_email(params[:email])
    
    if params.has_key?(:use_password)
      user.use_password = params[:use_password]
      if user.save
        response = { :success => true }
      else
        response = { :success => false }
      end
    else
      response = { :success => false }
    end
    
    render json: response
  end
end
