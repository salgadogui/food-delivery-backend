require 'rails_helper'

RSpec.describe Store, type: :model do
  it 'creates a store using FactoryBot' do
    store = create(:store)
    
    expect(store).to be_persisted
    expect(store.name).to eq("Test Store") 
  end
end
