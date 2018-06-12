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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180607063115) do

  create_table "admins", force: :cascade do |t|
    t.string "user_name"
    t.string "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "degrees", force: :cascade do |t|
    t.integer "division_id"
    t.string "code"
    t.string "name"
    t.integer "years"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["division_id"], name: "index_degrees_on_division_id"
  end

  create_table "divisions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fake_subjects", force: :cascade do |t|
    t.string "subject_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rgep_clusters", force: :cascade do |t|
    t.string "name"
    t.integer "units"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "study_path_subjects", force: :cascade do |t|
    t.integer "study_path_id"
    t.integer "subject_id"
    t.integer "rgep"
    t.string "year"
    t.string "semester"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "study_paths", force: :cascade do |t|
    t.integer "degree_id"
    t.string "program_revision_code"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["degree_id"], name: "index_study_paths_on_degree_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.integer "division_id"
    t.integer "fake_subject_id"
    t.string "subject_id"
    t.string "name"
    t.string "pre_req"
    t.string "description"
    t.integer "units"
    t.boolean "isGe"
    t.string "rgep"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["division_id"], name: "index_subjects_on_division_id"
    t.index ["fake_subject_id"], name: "index_subjects_on_fake_subject_id"
  end

end
