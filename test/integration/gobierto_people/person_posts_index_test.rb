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

    def latest_posts
      @latest_posts ||= [
        gobierto_people_person_posts(:richard_about_me),
        gobierto_people_person_posts(:richard_achievements)
      ]
    end

    def test_person_posts_index
      with_current_site(site) do
        visit @path

        assert has_selector?("h2", text: "Blogs")
      end
    end

    def test_person_posts_summary
      with_current_site(site) do
        visit @path

        within ".posts-summary" do
          latest_posts.each do |person_post|
            assert has_selector?(".person-post-excerpt", text: person_post.title)

            Array(person_post.tags).each do |person_post_tag|
              assert has_link?("##{person_post_tag}")
            end

            assert has_link?(person_post.title)
            assert has_link?("Continue reading")
            assert has_link?(person_post.person.name)
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
