# frozen_string_literal: true

module Integration
  module MatcherHelpers
    def has_message?(text)
      within ".flash-message" do
        has_content?(text)
      end
    end

    def has_no_message?(text)
      within ".flash-message" do
        has_no_content?(text)
      end
    end

    def has_alert?(text)
      within ".alert" do
        has_content?(text)
      end
    end
  end
end
