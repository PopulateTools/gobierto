# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  class PeoplePoliticalGroupsTest < ActionDispatch::IntegrationTest

    def setup
      super
      @path = gobierto_people_political_group_people_path(:marvel)
      disable_submodule(site, :departments)
    end

    def site
      @site ||= sites(:madrid)
    end

    def political_groups
      @political_groups ||= [
        gobierto_common_terms(:marvel_term),
        gobierto_common_terms(:dc_term)
      ]
    end

    def dc_member
      gobierto_people_people(:neil)
    end

    def other_site_member
      gobierto_people_people(:kali)
    end

    def test_current_political_group_higlight
      with_current_site(site) do
        visit @path
        within 'menu div div li.active' do
          assert has_link?('Marvel')
        end
      end
    end

    def test_absence_of_empty_political_group
      with_current_site(site) do
        visit @path

        within '.filter_boxed' do
          assert has_link?('Marvel')
          assert has_link?('DC')
        end
        dc_member.delete
        other_site_member.update(political_group: political_groups.last)

        click_link 'Political groups'
        sleep 1

        within '.filter_boxed' do
          assert has_link?('Marvel')
          assert has_no_link?('DC')
        end
      end
    end
  end
end
