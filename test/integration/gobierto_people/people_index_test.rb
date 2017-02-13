require "test_helper"

module GobiertoPeople
  class PeopleIndexTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_people_people_path
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

        assert has_selector?("h1", text: "#{site.name}'s organization chart")
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
  end
end
