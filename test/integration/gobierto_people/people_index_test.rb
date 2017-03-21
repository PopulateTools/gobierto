require "test_helper"

module GobiertoPeople
  class PeopleIndexTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_people_people_path
      @path_for_json = gobierto_people_people_path(format: :json)
      @path_for_csv = gobierto_people_people_path(format: :csv)
    end

    def site
      @site ||= sites(:madrid)
    end

    def people
      @people ||= [
        gobierto_people_people(:richard),
        gobierto_people_people(:tamara)
      ]
    end

    def political_groups
      @political_groups ||= [
        gobierto_people_political_groups(:marvel),
        gobierto_people_political_groups(:dc)
      ]
    end

    def test_people_index
      with_current_site(site) do
        visit @path

        assert has_selector?("h2", text: "#{site.name}'s organization chart")
      end
    end

    def test_people_filter
      with_current_site(site) do
        visit @path

        within ".filter_boxed" do
          assert has_link?("Government Team")
          assert has_link?("Opposition")
          assert has_link?("Executive")
          assert has_link?("All")
          assert has_link?("Political groups")
        end
      end
    end

    def test_people_summary
      with_current_site(site) do
        visit @path

        within ".people-summary" do
          people.each do |person|
            assert has_selector?(".person-item", text: person.name)
            assert has_link?(person.name)
          end
        end
      end
    end

    def test_subscription_block
      with_current_site(site) do
        visit @path

        within ".subscribable-box", match: :first do
          assert has_button?("Subscribe")
        end
      end
    end

    def test_people_index_json
      with_current_site(site) do
        get @path_for_json

        json_response = JSON.parse(response.body)
        assert_equal json_response.last["name"], "Tamara Devoux"
        assert_equal json_response.last["email"], "tamara@example.com"
      end
    end

    def test_people_index_csv
      with_current_site(site) do
        get @path_for_csv

        csv_response = CSV.parse(response.body, headers: true)
        assert_equal csv_response.by_row[1]["name"], "Tamara Devoux"
        assert_equal csv_response.by_row[1]["email"], "tamara@example.com"
      end
    end
  end
end
