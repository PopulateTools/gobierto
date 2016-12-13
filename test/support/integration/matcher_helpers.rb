module Integration
  module MatcherHelpers
    def has_message?(text)
      within ".flash-message" do
        has_content?(text)
      end
    end
  end
end
