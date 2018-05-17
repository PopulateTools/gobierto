# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  class InterestGroupTest < ActiveSupport::TestCase

    def google
      @google ||= gobierto_people_interest_groups(:google)
    end

    def accenture
      @accenture ||= gobierto_people_interest_groups(:accenture)
    end

    def test_status
      assert_equal "Inscribed", google.status
      assert_nil accenture.status
    end

  end
end
