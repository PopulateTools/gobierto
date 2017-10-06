# frozen_string_literal: true

require 'test_helper'

module GobiertoPeople
  module People
    class CustomLinksNavigationTest < ActionDispatch::IntegrationTest

      def site
        @site ||= sites(:madrid)
      end

      def richard
        @richard ||= gobierto_people_people(:richard)
      end

      def tamara
        @tamara ||= gobierto_people_people(:tamara)
      end

      def test_custom_links_navigation
        with_current_site(site) do
          visit gobierto_people_person_path(richard.slug)

          within '.people-navigation' do
            assert has_link?('Trips')
            assert has_link?('Gifts')
          end

          visit gobierto_people_person_path(tamara.slug)
          
          within '.people-navigation' do
            refute has_link?('Trips')
            refute has_link?('Gifts')
          end
        end
      end

    end
  end
end
