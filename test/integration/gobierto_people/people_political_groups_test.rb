# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  class PeoplePoliticalGroupsTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_people_political_group_people_path(:marvel)
    end

    def site
      @site ||= sites(:madrid)
    end

    def political_groups
      @political_groups ||= [
        gobierto_people_political_groups(:marvel),
        gobierto_people_political_groups(:dc)
      ]
    end

    def dc_member
      gobierto_people_people(:neil)
    end


    def test_absence_of_empty_political_group
      with_current_site(site) do
        visit @path

        within '.filter_boxed' do
          assert has_link?('Marvel')
          assert has_link?('DC')
        end
        dc_member.delete

        click_link 'Political groups'
        sleep 1

        within '.filter_boxed' do
          assert has_link?('Marvel')
          refute has_link?('DC')
        end
      end
    end
  end
end
