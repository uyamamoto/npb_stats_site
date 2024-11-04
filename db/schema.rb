# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_11_04_133542) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "batting_stats", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.integer "year"
    t.string "team"
    t.integer "games"
    t.integer "plate_appearances"
    t.integer "at_bats"
    t.integer "runs"
    t.integer "hits"
    t.integer "doubles"
    t.integer "triples"
    t.integer "home_runs"
    t.integer "total_bases"
    t.integer "rbi"
    t.integer "stolen_bases"
    t.integer "caught_stealing"
    t.integer "sacrifice_bunts"
    t.integer "sacrifice_flies"
    t.integer "walks"
    t.integer "hit_by_pitch"
    t.integer "strikeouts"
    t.integer "gidp"
    t.decimal "avg"
    t.decimal "slg"
    t.decimal "obp"
    t.decimal "ops"
    t.decimal "k_percentage"
    t.decimal "bb_percentage"
    t.decimal "bb_k"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_batting_stats_on_player_id"
  end

  create_table "pitching_stats", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.integer "year"
    t.string "team"
    t.integer "games"
    t.integer "wins"
    t.integer "losses"
    t.integer "saves"
    t.integer "holds"
    t.integer "hold_points"
    t.integer "complete_games"
    t.integer "shutouts"
    t.integer "no_walks"
    t.decimal "win_percentage"
    t.integer "batters_faced"
    t.decimal "innings"
    t.integer "hits"
    t.integer "home_runs"
    t.integer "walks"
    t.integer "hit_by_pitch"
    t.integer "strikeouts"
    t.integer "wild_pitches"
    t.integer "balks"
    t.integer "runs"
    t.integer "earned_runs"
    t.decimal "era"
    t.decimal "whip"
    t.decimal "k_per_nine"
    t.decimal "bb_per_nine"
    t.decimal "k_bb"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_pitching_stats_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "url"
    t.string "name"
    t.string "team"
    t.string "number"
    t.string "kana"
    t.string "photo_url"
    t.string "position"
    t.string "throws_bats"
    t.string "height_weight"
    t.string "birthdate"
    t.string "career"
    t.string "draft"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "batting_stats", "players"
  add_foreign_key "pitching_stats", "players"
end
