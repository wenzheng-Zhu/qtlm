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

ActiveRecord::Schema.define(version: 2018_08_15_093609) do

  create_table "access_tokens", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "open_id"
    t.decimal "total_price", precision: 10
    t.decimal "sum_price", precision: 10
    t.text "stuff"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wx_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "open_id"
    t.string "phone"
    t.boolean "member"
    t.decimal "bonus", precision: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "rank"
  end

end
