# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  class PersonStatementsIndexTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_people_statements_path
      @path_for_json = gobierto_people_statements_path(format: :json)
      @path_for_csv = gobierto_people_statements_path(format: :csv)
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

        assert has_selector?("h2", text: "Statements")
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
      skip "Subscription boxes are disabled"

      with_current_site(site) do
        visit @path

        within ".subscribable-box", match: :first do
          assert has_button?("Subscribe")
        end
      end
    end

    def test_person_statements_index_json
      with_current_site(site) do
        get @path_for_json

        json_response = JSON.parse(response.body)
        assert_equal json_response.first["person_name"], "Richard Rider"
        assert_equal json_response.first["title"], "Declaración de Bienes y Actividades"
        assert_equal json_response.second["title"], "Declaración de Bienes y Actividades (pasada)"
      end
    end

    def test_person_statements_index_csv
      with_current_site(site) do
        get @path_for_csv

        csv_response = CSV.parse(response.body, headers: true)
        assert_equal csv_response.by_row[0]["person_name"], "Richard Rider"
        assert_equal csv_response.by_row[0]["title"], "Declaración de Bienes y Actividades"
        assert_equal csv_response.by_row[1]["title"], "Declaración de Bienes y Actividades (pasada)"
      end
    end
  end
end
