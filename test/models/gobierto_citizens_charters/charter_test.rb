# frozen_string_literal: true

require "test_helper"

module GobiertoCitizensCharters
  class CharterTest < ActiveSupport::TestCase
    def charter
      @charter ||= gobierto_citizens_charters_charters(:teleassistance_charter)
    end

    def category
      @category ||= gobierto_common_terms(:social_services_term)
    end

    def test_valid
      assert charter.valid?
    end

    def test_category
      assert_equal category, charter.category
    end
  end
end
