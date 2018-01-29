# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class CategoryTest < ActiveSupport::TestCase
    def category
      @category ||= gobierto_plans_categories(:basic_needs)
    end

    def test_valid
      assert category.valid?
    end
  end
end
