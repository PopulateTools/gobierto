require "test_helper"

module GobiertoPeople
  class WelcomeIndexTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_people_root_path
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_welcome_index
      with_current_site(site) do
        visit @path

        assert has_selector?("h1", text: "Know the people who work to make your city a better place to live.")
        assert has_selector?(".people-summary")
        assert has_selector?(".events-summary")
        assert has_selector?(".posts-summary")
      end
    end
  end
end
