require "test_helper"

module GobiertoPeople
  class PersonPostsIndexTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_people_posts_path
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_person_posts_index
      with_current_site(site) do
        visit @path

        assert has_selector?("h1", text: "Blogs")
        assert has_selector?(".posts-summary")
      end
    end
  end
end
