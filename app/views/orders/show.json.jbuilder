json.extract! @order, :id, :state, :user_id, :total_value, :created_at, :updated_at, :store_id

json.order_items @order.order_items do |order_item|
  json.extract! order_item, :id, :product, :quantity, :price, :created_at, :updated_at
end

json.store @order.store, :id, :name
json.user @order.user, :id, :email
