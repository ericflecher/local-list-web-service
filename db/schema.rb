# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130326233335) do

  create_table "places", :force => true do |t|
    t.string   "name"
    t.string   "location"
    t.string   "ot_rid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "uid"
    t.string   "city"
  end

  create_table "saved_places", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "come_back"
    t.integer  "user_id"
    t.string   "yelp_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "token"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "password_hash"
    t.string   "password_salt"
    t.boolean  "use_password"
  end

end
