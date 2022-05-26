# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_01_14_112046) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admin_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "comments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "order_id", null: false
    t.uuid "user_id", null: false
    t.string "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_comments_on_order_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "friendships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "friend_id"
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "activity_score", default: 0
    t.index ["friend_id"], name: "index_friendships_on_friend_id"
    t.index ["user_id", "friend_id"], name: "index_friendships_on_user_id_and_friend_id", unique: true
    t.index ["user_id"], name: "index_friendships_on_user_id"
  end

  create_table "games", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "sportradar_id"
    t.uuid "sport_id", null: false
    t.integer "home_team_score"
    t.integer "away_team_score"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "game_status", default: 0
    t.string "week"
    t.uuid "home_team_id"
    t.uuid "away_team_id"
    t.datetime "scheduled_time"
    t.uuid "market_id"
    t.integer "quarter"
    t.string "clock"
    t.index ["away_team_id"], name: "index_games_on_away_team_id"
    t.index ["home_team_id"], name: "index_games_on_home_team_id"
    t.index ["market_id"], name: "index_games_on_market_id"
    t.index ["sport_id"], name: "index_games_on_sport_id"
  end

  create_table "likes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "order_id", null: false
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_likes_on_order_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "markets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sport_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["sport_id"], name: "index_markets_on_sport_id"
  end

  create_table "orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "title"
    t.boolean "short"
    t.integer "price_per_share"
    t.integer "num_shares"
    t.integer "total_value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "player_game_id", null: false
    t.boolean "compliant", default: false
    t.uuid "market_id"
    t.integer "privacy", default: 0
    t.boolean "refunded", default: false
    t.uuid "ride_fade_id"
    t.index ["market_id"], name: "index_orders_on_market_id"
    t.index ["player_game_id"], name: "index_orders_on_player_game_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payouts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "player_game_id", null: false
    t.uuid "order_id", null: false
    t.integer "amount"
    t.integer "status", default: 0
    t.datetime "created"
    t.datetime "completed"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "market_id"
    t.index ["market_id"], name: "index_payouts_on_market_id"
    t.index ["order_id"], name: "index_payouts_on_order_id"
    t.index ["player_game_id"], name: "index_payouts_on_player_game_id"
  end

  create_table "platform_variables", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "variable_name"
    t.integer "value", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "player_game_stats", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "stat_name"
    t.float "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "player_sportradar_id"
    t.string "game_sportradar_id"
    t.uuid "player_game_id"
    t.index ["player_game_id"], name: "index_player_game_stats_on_player_game_id"
  end

  create_table "player_games", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "player_id", null: false
    t.uuid "game_id", null: false
    t.datetime "date"
    t.float "score"
    t.float "projection", default: 0.0
    t.integer "injury_status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "shares_bought", default: 0
    t.integer "shares_sold", default: 0
    t.uuid "market_id"
    t.integer "dollars_bought", default: 0
    t.integer "dollars_sold", default: 0
    t.index ["game_id"], name: "index_player_games_on_game_id"
    t.index ["market_id"], name: "index_player_games_on_market_id"
    t.index ["player_id"], name: "index_player_games_on_player_id"
  end

  create_table "players", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "sportradar_id"
    t.uuid "sport_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "position"
    t.uuid "team_id"
    t.index ["sport_id"], name: "index_players_on_sport_id"
    t.index ["team_id"], name: "index_players_on_team_id"
  end

  create_table "sports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "teams", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sport_id", null: false
    t.string "sportradar_id"
    t.string "alias"
    t.string "name"
    t.string "market"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["sport_id"], name: "index_teams_on_sport_id"
  end

  create_table "transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.boolean "deposit"
    t.integer "status", default: 0
    t.integer "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "bonus_amount", default: 0
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "jti", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "winnings", default: 0
    t.integer "bonus_balance", default: 0
    t.string "color"
    t.string "reset_code"
    t.string "first_name"
    t.string "last_name"
    t.string "username"
    t.integer "order_privacy", default: 0
    t.integer "tsevo_status", default: 0
    t.date "date_of_birth"
    t.integer "unplayed_deposits", default: 0
    t.integer "activity_score", default: 0
    t.string "one_signal_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "orders"
  add_foreign_key "comments", "users"
  add_foreign_key "friendships", "users"
  add_foreign_key "friendships", "users", column: "friend_id"
  add_foreign_key "games", "markets"
  add_foreign_key "games", "sports"
  add_foreign_key "games", "teams", column: "away_team_id"
  add_foreign_key "games", "teams", column: "home_team_id"
  add_foreign_key "likes", "orders"
  add_foreign_key "likes", "users"
  add_foreign_key "markets", "sports"
  add_foreign_key "orders", "markets"
  add_foreign_key "orders", "users"
  add_foreign_key "payouts", "markets"
  add_foreign_key "payouts", "orders"
  add_foreign_key "payouts", "player_games"
  add_foreign_key "player_game_stats", "player_games"
  add_foreign_key "player_games", "games"
  add_foreign_key "player_games", "markets"
  add_foreign_key "player_games", "players"
  add_foreign_key "players", "sports"
  add_foreign_key "players", "teams"
  add_foreign_key "teams", "sports"
  add_foreign_key "transactions", "users"
end
