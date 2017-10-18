# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_admin/authorizable_resource_test_module"

module GobiertoAdmin
  module GobiertoPeople
    class PersonStatementsIndexTest < ActionDispatch::IntegrationTest

      include ::GobiertoAdmin::AuthorizableResourceTestModule

      def setup
        super
        @path = admin_people_person_statements_path(person)
        setup_authorizable_resource_test(gobierto_admin_admins(:steve), @path)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def test_person_statements_index
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "table.person-statements-list tbody" do
              assert has_selector?("tr", count: person.statements.count)

              person.statements.each do |statement|
                assert has_selector?("tr#person-statement-item-#{statement.id}")

                within "tr#person-statement-item-#{statement.id}" do
                  if statement.active?
                    assert has_content?("Published")
                  else
                    assert has_content?("Draft")
                  end
                  assert has_link?("View statement")
                end
              end
            end
          end
        end
      end
    end
  end
end
