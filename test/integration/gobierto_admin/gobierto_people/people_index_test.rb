# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class PeopleIndexTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_people_people_path
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def people
        @people ||= site.people
      end

      def test_people_index
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "table.people-list tbody" do
              assert has_selector?("tr", count: people.size)

              people.each do |person|
                assert has_selector?("tr#person-item-#{person.id}")

                within "tr#person-item-#{person.id}" do
                  if person.active?
                    assert has_content?("Published")
                  else
                    assert has_content?("Draft")
                  end
                  assert has_link?("View person")
                end
              end
            end
          end
        end
      end
    end
  end
end
