json.extract! product, :id, :store_id, :name, :price, :created_at, :updated_at
json.url store_products_url(product, format: :json)
