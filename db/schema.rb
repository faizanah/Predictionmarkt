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

ActiveRecord::Schema.define(version: 2018_04_02_202018) do

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admin_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0, null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
  end

  create_table "contract_trade_stats", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "interval", null: false
    t.datetime "interval_at", null: false
    t.bigint "contract_id", null: false
    t.bigint "market_id", null: false
    t.bigint "market_outcome_id", null: false
    t.integer "currency", null: false
    t.integer "quantity", null: false
    t.decimal "amount", precision: 42, default: "0", null: false
    t.integer "user_quantity", null: false
    t.decimal "user_amount", precision: 42, default: "0", null: false
    t.decimal "open_odds", precision: 6, scale: 4, default: "0.0", null: false
    t.decimal "close_odds", precision: 6, scale: 4, default: "0.0", null: false
    t.decimal "min_odds", precision: 6, scale: 4, default: "0.0", null: false
    t.decimal "max_odds", precision: 6, scale: 4, default: "0.0", null: false
    t.decimal "mean_odds", precision: 6, scale: 4, default: "0.0", null: false
    t.decimal "sos_odds", precision: 6, scale: 4, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_contract_trade_stats_on_contract_id"
    t.index ["interval_at", "contract_id"], name: "cts_composite1"
    t.index ["interval_at", "market_outcome_id"], name: "cts_composite2"
    t.index ["market_id"], name: "index_contract_trade_stats_on_market_id"
    t.index ["market_outcome_id"], name: "index_contract_trade_stats_on_market_outcome_id"
  end

  create_table "contract_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "reason", null: false
    t.integer "prev_id"
    t.bigint "contract_id", null: false
    t.bigint "user_id", null: false
    t.integer "total_change", default: 0, null: false
    t.integer "escrow_total_change", default: 0, null: false
    t.integer "total", default: 0, null: false
    t.integer "escrow_total", default: 0, null: false
    t.integer "market_id", null: false
    t.integer "market_outcome_id", null: false
    t.integer "cause_id", null: false
    t.string "cause_type", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cause_type", "cause_id"], name: "index_contract_transactions_on_cause_type_and_cause_id"
    t.index ["contract_id"], name: "index_contract_transactions_on_contract_id"
    t.index ["market_id", "market_outcome_id"], name: "contract_market"
    t.index ["user_id", "contract_id", "prev_id"], name: "contract_prev_id", unique: true
    t.index ["user_id"], name: "index_contract_transactions_on_user_id"
  end

  create_table "contracts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "ticker", null: false
    t.bigint "market_id", null: false
    t.bigint "market_outcome_id", null: false
    t.integer "currency", null: false
    t.decimal "settle_price", precision: 42, null: false
    t.integer "state", null: false
    t.text "details"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["market_id", "market_outcome_id", "currency"], name: "contracts_unique_outcomes", unique: true
    t.index ["market_id"], name: "index_contracts_on_market_id"
    t.index ["market_outcome_id"], name: "index_contracts_on_market_outcome_id"
    t.index ["ticker"], name: "index_contracts_on_ticker", unique: true
  end

  create_table "currency_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "reason", null: false
    t.integer "prev_id"
    t.integer "currency", null: false
    t.bigint "user_id", null: false
    t.decimal "total_change", precision: 42, default: "0", null: false
    t.decimal "escrow_total_change", precision: 42, default: "0", null: false
    t.decimal "total", precision: 42, default: "0", null: false
    t.decimal "escrow_total", precision: 42, default: "0", null: false
    t.integer "cause_id", null: false
    t.string "cause_type", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cause_type", "cause_id"], name: "index_currency_transactions_on_cause_type_and_cause_id"
    t.index ["user_id", "currency", "prev_id"], name: "currency_prev_id", unique: true
    t.index ["user_id"], name: "index_currency_transactions_on_user_id"
  end

  create_table "currency_transfers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "reason", null: false
    t.integer "state", null: false
    t.decimal "total_change", precision: 42, null: false
    t.integer "currency", null: false
    t.bigint "user_id", null: false
    t.integer "lock_version", default: 0, null: false
    t.string "receiving_address", null: false
    t.string "receiving_transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "reason", "state"], name: "index_currency_transfers_on_user_id_and_reason_and_state"
    t.index ["user_id"], name: "index_currency_transfers_on_user_id"
  end

  create_table "events", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "details"
    t.string "ip_address"
    t.string "user_agent"
    t.string "request_id"
    t.integer "cause_id", null: false
    t.string "cause_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cause_type", "cause_id"], name: "index_events_on_cause_type_and_cause_id"
    t.index ["created_at"], name: "index_events_on_created_at"
    t.index ["ip_address"], name: "index_events_on_ip_address"
    t.index ["request_id"], name: "index_events_on_request_id"
  end

  create_table "market_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.integer "parent_id"
    t.integer "lft", null: false
    t.integer "rgt", null: false
    t.text "details"
    t.integer "depth", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lft"], name: "index_market_categories_on_lft"
    t.index ["name"], name: "index_market_categories_on_name"
    t.index ["parent_id"], name: "index_market_categories_on_parent_id"
    t.index ["rgt"], name: "index_market_categories_on_rgt"
  end

  create_table "market_categories_markets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "market_id", null: false
    t.bigint "market_category_id", null: false
    t.index ["market_category_id"], name: "index_market_categories_markets_on_market_category_id"
    t.index ["market_id", "market_category_id"], name: "unique_markets_in_category", unique: true
    t.index ["market_id"], name: "index_market_categories_markets_on_market_id"
  end

  create_table "market_outcomes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.string "short_title"
    t.string "external_id"
    t.string "ticker", null: false
    t.integer "outcome_type", null: false
    t.bigint "market_id", null: false
    t.text "details"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["market_id", "title"], name: "index_market_outcomes_on_market_id_and_title", unique: true
    t.index ["market_id"], name: "index_market_outcomes_on_market_id"
    t.index ["ticker"], name: "index_market_outcomes_on_ticker", unique: true
  end

  create_table "market_shares_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "reason", null: false
    t.integer "prev_id"
    t.bigint "market_id", null: false
    t.integer "currency", null: false
    t.integer "total_change", default: 0, null: false
    t.integer "escrow_total_change", default: 0, null: false
    t.integer "total", default: 0, null: false
    t.integer "escrow_total", default: 0, null: false
    t.integer "cause_id", null: false
    t.string "cause_type", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cause_type", "cause_id"], name: "index_market_shares_transactions_on_cause_type_and_cause_id"
    t.index ["market_id", "currency", "prev_id"], name: "market_shares_prev_id", unique: true
    t.index ["market_id"], name: "index_market_shares_transactions_on_market_id"
  end

  create_table "market_specs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "type"
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "markets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.string "external_id"
    t.string "ticker", null: false
    t.text "details"
    t.bigint "user_id", null: false
    t.bigint "winner_outcome_id"
    t.integer "market_type", null: false
    t.integer "state", null: false
    t.datetime "start_date"
    t.datetime "close_date"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "market_spec_id"
    t.index ["close_date"], name: "index_markets_on_close_date"
    t.index ["market_spec_id"], name: "index_markets_on_market_spec_id"
    t.index ["start_date"], name: "index_markets_on_start_date"
    t.index ["ticker"], name: "index_markets_on_ticker", unique: true
    t.index ["user_id"], name: "index_markets_on_user_id"
    t.index ["winner_outcome_id"], name: "index_markets_on_winner_outcome_id"
  end

  create_table "referral_codes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "code", null: false
    t.bigint "user_id", null: false
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_referral_codes_on_code", unique: true
    t.index ["user_id"], name: "index_referral_codes_on_user_id"
  end

  create_table "referred_visitors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "details"
    t.bigint "referral_code_id", null: false
    t.bigint "referred_id"
    t.bigint "referrer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["referral_code_id"], name: "index_referred_visitors_on_referral_code_id"
    t.index ["referred_id"], name: "index_referred_visitors_on_referred_id"
    t.index ["referrer_id"], name: "index_referred_visitors_on_referrer_id"
  end

  create_table "trades", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "state", null: false
    t.integer "trade_type", null: false
    t.integer "ask_order_id", null: false
    t.integer "bid_order_id", null: false
    t.bigint "contract_id", null: false
    t.bigint "market_id", null: false
    t.bigint "market_outcome_id", null: false
    t.integer "currency", null: false
    t.integer "quantity", null: false
    t.decimal "price", precision: 42, default: "0", null: false
    t.decimal "amount", precision: 42, default: "0", null: false
    t.text "details"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ask_order_id"], name: "index_trades_on_ask_order_id"
    t.index ["bid_order_id"], name: "index_trades_on_bid_order_id"
    t.index ["contract_id"], name: "index_trades_on_contract_id"
    t.index ["market_id", "contract_id", "created_at", "trade_type"], name: "trades_comboindex_time"
    t.index ["market_id", "created_at"], name: "index_trades_on_market_id_and_created_at"
    t.index ["market_id"], name: "index_trades_on_market_id"
    t.index ["market_outcome_id"], name: "index_trades_on_market_outcome_id"
    t.index ["state", "market_id", "contract_id", "trade_type"], name: "trades_comboindex"
  end

  create_table "trades_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "trade_id", null: false
    t.bigint "user_id", null: false
    t.index ["trade_id"], name: "index_trades_users_on_trade_id"
    t.index ["user_id"], name: "index_trades_users_on_user_id"
  end

  create_table "trading_orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "state", null: false
    t.integer "order_type", null: false
    t.integer "operation", null: false
    t.integer "time_in_force", null: false
    t.bigint "user_id", null: false
    t.bigint "contract_id", null: false
    t.bigint "market_id", null: false
    t.bigint "market_outcome_id", null: false
    t.integer "filled_quantity"
    t.integer "requested_quantity"
    t.integer "escrowed_quantity"
    t.decimal "filled_amount", precision: 42
    t.decimal "requested_amount", precision: 42
    t.decimal "escrowed_amount", precision: 42
    t.decimal "limit_price", precision: 42
    t.decimal "stop_price", precision: 42
    t.datetime "expires_at"
    t.text "details"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_trading_orders_on_contract_id"
    t.index ["created_at"], name: "index_trading_orders_on_created_at"
    t.index ["expires_at"], name: "index_trading_orders_on_expires_at"
    t.index ["market_id"], name: "index_trading_orders_on_market_id"
    t.index ["market_outcome_id"], name: "index_trading_orders_on_market_outcome_id"
    t.index ["state", "market_id", "contract_id", "order_type", "operation", "limit_price"], name: "trading_orders_combo_limit"
    t.index ["state", "market_id", "contract_id", "stop_price"], name: "trading_orders_combo_stop"
    t.index ["state", "user_id", "market_id", "contract_id"], name: "trading_orders_userindex"
    t.index ["user_id"], name: "index_trading_orders_on_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_type", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "details"
    t.integer "lock_version", default: 0, null: false
    t.string "provider"
    t.string "uid"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider"], name: "index_users_on_provider"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid"], name: "index_users_on_uid"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "wallet_credentials", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "currency", null: false
    t.integer "state", null: false
    t.string "address", null: false
    t.string "public_key", null: false
    t.string "encrypted_private_key", null: false
    t.text "details"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_wallet_credentials_on_address", unique: true
  end

  create_table "wallet_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "reason", null: false
    t.bigint "wallet_id", null: false
    t.bigint "currency_transfer_id"
    t.integer "prev_id"
    t.decimal "total_change", precision: 42, default: "0", null: false
    t.decimal "escrow_total_change", precision: 42, default: "0", null: false
    t.decimal "total", precision: 42, default: "0", null: false
    t.decimal "escrow_total", precision: 42, default: "0", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_transfer_id"], name: "index_wallet_transactions_on_currency_transfer_id"
    t.index ["wallet_id", "prev_id"], name: "wallet_prev_id", unique: true
    t.index ["wallet_id"], name: "index_wallet_transactions_on_wallet_id"
  end

  create_table "wallets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "currency", null: false
    t.integer "state", null: false
    t.string "address", null: false
    t.bigint "user_id"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_wallets_on_address", unique: true
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  create_table "withdrawal_orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "state", null: false
    t.integer "currency_transfer_id", null: false
    t.integer "residual_wallet_id", null: false
    t.text "details"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_transfer_id"], name: "index_withdrawal_orders_on_currency_transfer_id"
    t.index ["residual_wallet_id"], name: "index_withdrawal_orders_on_residual_wallet_id"
  end

  add_foreign_key "contract_trade_stats", "contracts"
  add_foreign_key "contract_trade_stats", "market_outcomes"
  add_foreign_key "contract_trade_stats", "markets"
  add_foreign_key "contract_transactions", "contracts"
  add_foreign_key "contract_transactions", "users"
  add_foreign_key "contracts", "market_outcomes"
  add_foreign_key "contracts", "markets"
  add_foreign_key "currency_transactions", "users"
  add_foreign_key "currency_transfers", "users"
  add_foreign_key "market_categories_markets", "market_categories"
  add_foreign_key "market_categories_markets", "markets"
  add_foreign_key "market_outcomes", "markets"
  add_foreign_key "market_shares_transactions", "markets"
  add_foreign_key "markets", "users"
  add_foreign_key "referral_codes", "users"
  add_foreign_key "referred_visitors", "referral_codes"
  add_foreign_key "trades", "contracts"
  add_foreign_key "trades", "market_outcomes"
  add_foreign_key "trades", "markets"
  add_foreign_key "trades_users", "trades"
  add_foreign_key "trades_users", "users"
  add_foreign_key "trading_orders", "contracts"
  add_foreign_key "trading_orders", "market_outcomes"
  add_foreign_key "trading_orders", "markets"
  add_foreign_key "trading_orders", "users"
  add_foreign_key "wallet_transactions", "currency_transfers"
  add_foreign_key "wallet_transactions", "wallets"
end
