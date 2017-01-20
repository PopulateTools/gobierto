require "test_helper"

module GobiertoAdmin
  class SiteHelperTest < ActionView::TestCase
    def active_site
      @active_site ||= sites(:madrid)
    end

    def draft_site
      @draft_site ||= sites(:santander)
    end

    def test_site_visibility_level_badge_for_draft_site
      visibility_level_badge_markup =
        '<span>' \
          '<i class="fa fa-lock"></i>' \
          'Draft' \
        '</span>'

      assert_equal visibility_level_badge_markup,
        site_visibility_level_badge_for(draft_site)
    end

    def test_site_visibility_level_badge_for_active_site
      visibility_level_badge_markup =
        '<span>' \
          '<i class="fa fa-unlock"></i>' \
          'Published' \
        '</span>'

      assert_equal visibility_level_badge_markup,
        site_visibility_level_badge_for(active_site)
    end
  end
end
