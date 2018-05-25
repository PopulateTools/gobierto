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

    def test_registry
      assert_equal "Registry of Interest Groups of Madrid City Council", google.registry
      assert_nil accenture.registry
    end

  end
end
