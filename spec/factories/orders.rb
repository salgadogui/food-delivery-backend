FactoryBot.define do
  factory :order do
    quantity { 1 }
    association :product
    store { product.store }
  end
end
