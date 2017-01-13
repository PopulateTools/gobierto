require "test_helper"

module GobiertoPeople
  class PoliticalGroupTest < ActiveSupport::TestCase
    def political_group
      @political_group ||= gobierto_people_political_groups(:marvel)
    end

    def test_valid
      assert political_group.valid?
    end
  end
end
