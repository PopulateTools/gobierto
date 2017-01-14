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

    def test_people_index
      with_current_site(site) do
        visit @path

        assert has_selector?("h1", text: "Organization chart")
        assert has_selector?(".people-summary")
      end
    end
  end
end
