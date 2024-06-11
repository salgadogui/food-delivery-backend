# spec/controllers/orders_controller_spec.rb
require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  describe 'POST #create' do
    before do
      @user = User.create!(
        email: "test@example.com", 
        password: "password", 
      )
    end

    context 'when the store is closed' do
      before do
        @store = Store.create!(
          name: "Closed Store", 
          user_id: @user.id, 
          state: "closed", 
          created_at: Time.now, 
          updated_at: Time.now
        )
      end

      it 'does not allow creating an order' do
        expect {
          post :create, params: { store_id: @store.id, order: { product_id: 1, quantity: 1 } }
        }.not_to change(Order, :count)
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Store is closed and cannot accept orders.")
      end
    end

    context 'when the store is open' do
      before do
        @store = Store.create!(
          name: "Open Store", 
          user_id: @user.id, 
          state: "open", 
          created_at: Time.now, 
          updated_at: Time.now
        )
        @product = Product.create!(
          name: "Test Product", 
          price: 10.0, 
          store_id: @store.id, 
          created_at: Time.now, 
          updated_at: Time.now
        )
      end

      it 'allows creating an order' do
        expect {
          post :create, params: { store_id: @store.id, order: { product_id: @product.id, quantity: 1 } }
        }.to change(Order, :count).by(1)
        
        expect(response).to have_http_status(:created)
      end
    end
  end
end

