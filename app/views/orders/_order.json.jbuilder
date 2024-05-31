json.extract! order, :id, :user_id, :store_id, :total_value, :created_at, :updated_at
json.url store_orders_url(order, format: :json)
