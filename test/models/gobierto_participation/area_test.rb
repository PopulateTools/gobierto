require "test_helper"

module GobiertoParticipation
  class AreaTest < ActiveSupport::TestCase
    def area
      @area ||= gobierto_participation_areas(:north)
    end

    def test_valid
      assert area.valid?
    end

    def test_find_by_slug
      assert_nil GobiertoParticipation::Area.find_by_slug! nil
      assert_nil GobiertoParticipation::Area.find_by_slug! ""
      assert_raises(ActiveRecord::RecordNotFound) do
        GobiertoParticipation::Area.find_by_slug! "foo"
      end

      assert_equal area, GobiertoParticipation::Area.find_by_slug!(area.slug_es)
      assert_equal area, GobiertoParticipation::Area.find_by_slug!(area.slug_en)
    end
  end
end
