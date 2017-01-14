require "test_helper"

module GobiertoPeople
  class PersonShowTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_people_person_path(person)
    end

    def site
      @site ||= sites(:madrid)
    end

    def person
      @person ||= gobierto_people_people(:richard)
    end

    def test_person_show
      with_current_site(site) do
        visit @path

        assert has_selector?("h1", text: person.name)
        assert has_selector?(".intro", text: person.charge)
      end
    end
  end
end
