# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessDecoratorTest < ActiveSupport::TestCase

    def active_group_decorator
      @active_group_decorator = ProcessDecorator.new(bowling_group)
    end

    def empty_group_decorator
      @empty_group_decorator = ProcessDecorator.new(green_city_group)
    end

    def bowling_group
      @bowling_group ||= gobierto_participation_processes(:bowling_group_very_active)
    end

    def green_city_group
      @green_city_group ||= gobierto_participation_processes(:green_city_group_active_empty)
    end

    def test_interactions_count
      assert_equal 0, empty_group_decorator.interactions_count
      assert_equal 8, active_group_decorator.interactions_count
    end

    def test_participants_count
      assert_equal 0, empty_group_decorator.participants_count
      assert_equal 3, active_group_decorator.participants_count
    end

  end
end
