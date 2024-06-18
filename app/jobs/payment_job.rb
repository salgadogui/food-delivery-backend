class PaymentJob < ApplicationJob
  queue_as :default

  def perform(order:, value:, number:, valid:, cvv:)
    params = { payment: { value: value, number: number, valid: valid, cvv: cvv } }
    response = con.post("/payments", params.to_json)

    if response.success?
      handle_successful_payment(order)
    else
      handle_failed_payment(order)
    end
  end
  
  private

    def config
      Rails.configuration.payment
    end

    def con
      @con ||= Faraday.new(
        url: config.host,
        headers: {
          "Content-Type" => "application/json",
          "Accept" => "application/json",
        }
      )
    end

    def handle_successful_payment(order)
      order.prepare_order
    end

    def handle_failed_payment(order)
      order.cancel_order
    end
end
