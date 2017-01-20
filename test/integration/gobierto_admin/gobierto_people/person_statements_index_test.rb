require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class PersonStatementsIndexTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_people_person_statements_path(person)
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
                    assert has_link?("View statement")
                  else
                    assert has_selector?(".view_item", text: "View statement")
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
