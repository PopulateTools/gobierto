require "test_helper"

module GobiertoPeople
  class PersonStatementsIndexTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_people_statements_path
    end

    def site
      @site ||= sites(:madrid)
    end

    def statements
      @statements ||= [
        gobierto_people_person_statements(:richard_current),
        gobierto_people_person_statements(:richard_past)
      ]
    end

    def test_person_statements_index
      with_current_site(site) do
        visit @path

        assert has_selector?("h1", text: "Statements")
      end
    end

    def test_person_statements_summary
      with_current_site(site) do
        visit @path

        within ".statements-summary" do
          statements.each do |statement|
            assert has_selector?(".person_statement-item", text: statement.title)
            assert has_link?(statement.title)
            assert has_link?(statement.person.name)
          end
        end
      end
    end

    def test_subscription_block
      with_current_site(site) do
        visit @path

        within ".subscribable-box" do
          assert has_button?("Subscribe")
        end
      end
    end
  end
end
