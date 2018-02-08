# frozen_string_literal: true

require "test_helper"
require "support/event_helpers"

module GobiertoCalendars
  class SluggableTest < ActiveSupport::TestCase
    include ::EventHelpers

    def test_assign_slug_with_date
      event_one = create_event(title: "_* (Title)-", starts_at: "2017-01-02 18:00:00")
      event_two = create_event(title: "_* (Title)--", starts_at: "2017-01-02 20:00:00")
      event_three = create_event(title: "_* (Title)_2", starts_at: "2017-01-02")

      assert_equal "#{Time.now.to_date.to_s}-title", event_one.slug
      assert_equal "#{Time.now.to_date.to_s}-title-2", event_two.slug
      assert_equal "#{Time.now.to_date.to_s}-title-2-2", event_three.slug
    end
  end
end
