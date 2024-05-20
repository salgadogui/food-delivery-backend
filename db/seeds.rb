apiKey = Credential.create_access :seller
apiKey.update_attribute :key, "ldd+iZEBZvJ9x3FVM2azZdTujDM="

admin = User.find_by(
  email: "admin@example.com"
)

if !admin
  admin = User.new(
    email: "admin@example.com",
    password: "123456",
    password_confirmation: "123456",
    role: :admin
  )
  admin.save!
end

usernames = ["Orange Curry", "Belly King"]
usernames.each do |username|
  user = User.new(
    email: "#{username.split.map { |s| s.downcase }.join(".")}@example.com",
    password: "123456",
    password_confirmation: "123456",
    role: :seller
  )
  user.save!

  stores = Array.new(5) { Faker::Company.name }
  stores.each do |store|
    Store.find_or_create_by!(
      name: store, user: user
    )

    products = Array.new(10) { Faker::Food.dish }
    products.each do |product|
      created_store = Store.find_by(name: store)
      Product.find_or_create_by!(
        title: product, price: rand(15..50), store: created_store
      )
    end
  end
end
