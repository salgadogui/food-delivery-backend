require "rails_helper"

RSpec.describe "Registrations", type: :request do

  let(:seller_credential) {
    seller_credential = Credential.create_access :seller
  }

  describe "POST /new" do
    it "creates a seller user" do
      post(
        "/new",
        headers: {
          "Accept" => "application/json",
          "X-API-KEY" => seller_credential.key
        },
        params: {
          user: {
            email: "test@example.com",
            password: "123456",
            password_confirmation: "123456",
          }
        }
      )
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["email"]).to eq("test@example.com")
    end

    it "returns an error for admin role" do
      post(
        "/new",
        headers: {
          "Accept" => "application/json",
          "X-API-KEY" => :admin
        },
        params: {
          user: {
            email: "admin@example.com",
            password: "123456",
            password_confirmation: "123456",
          }
        }
      )
      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)["error"]).to eq("Role admin is not allowed.")
    end
  end
end
