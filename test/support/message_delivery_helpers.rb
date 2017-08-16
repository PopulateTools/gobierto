# frozen_string_literal: true

class ActionMailer::MessageDelivery
  def deliver_later(_options = {})
    deliver_now
  end
end
