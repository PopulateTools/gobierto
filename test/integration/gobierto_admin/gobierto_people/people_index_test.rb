# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class PeopleIndexTest < ActionDispatch::IntegrationTest

      include PermissionHelpers

      def setup
        super
        @path = admin_people_people_path
      end

      def manager_admin
        @manager_admin ||= gobierto_admin_admins(:nick)
      end

      def regular_admin
        @regular_admin ||= gobierto_admin_admins(:tony)
      end

      def site
        @site ||= sites(:madrid)
      end

      def people
        @people ||= site.people
      end

      def manageable_person
        @manageable_person ||= gobierto_people_people(:richard)
      end

      def unmanageable_published_person
        @unmanageable_person ||= gobierto_people_people(:nelson)
      end

      def unmanageable_draft_person
        @unmanageable_draft_person ||= gobierto_people_people(:juana)
      end

      def test_people_index
        with_signed_in_admin(manager_admin) do
          with_current_site(site) do
            visit @path

            assert has_link? 'New person'

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

      def test_people_index_without_manage_all_permissions
        with_signed_in_admin(regular_admin) do
          with_current_site(site) do
            visit @path

            refute has_link? 'New person'

            within "#person-item-#{manageable_person.id}" do
              assert has_link? manageable_person.name
              assert has_link? 'View person'
              assert_equal 1, first('td').all('a').size
            end

            within "#person-item-#{unmanageable_published_person.id}" do
              refute has_link? unmanageable_published_person.name
              assert has_link? 'View person'
              assert first('td').all('a').empty?
            end

            within "#person-item-#{unmanageable_draft_person.id}" do
              refute has_link? unmanageable_draft_person.name
              refute has_link? 'View person'
              assert first('td').all('a').empty?
            end
          end
        end
      end

      def test_people_index_regular_admin_with_manage_all_permissions
        setup_specific_permissions(regular_admin, site: site, module: 'gobierto_people', all_people: true)

        with_signed_in_admin(regular_admin) do
          with_current_site(site) do
            visit @path

            assert has_link? 'New person'

            within "#person-item-#{manageable_person.id}" do
              assert has_link? manageable_person.name
              assert has_link? 'View person'
              assert_equal 1, first('td').all('a').size
            end

            within "#person-item-#{unmanageable_published_person.id}" do
              assert has_link? unmanageable_published_person.name
              assert has_link? 'View person'
              assert_equal 1, first('td').all('a').size
            end

            within "#person-item-#{unmanageable_draft_person.id}" do
              assert has_link? unmanageable_draft_person.name
              assert has_link? 'View person'
              assert_equal 1, first('td').all('a').size
            end
          end
        end
      end

    end
  end
end
