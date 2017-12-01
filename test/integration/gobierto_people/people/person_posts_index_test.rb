# frozen_string_literal: true

require "test_helper"
require_relative "base_index"

module GobiertoPeople
  module People
    class PersonPostsIndexTest < ActionDispatch::IntegrationTest
      include BaseIndex

      def setup
        super
        @path = gobierto_people_person_posts_path(person.slug)
      end

      def site
        @site ||= sites(:madrid)
      end

      def person
        @person ||= gobierto_people_people(:richard)
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

          assert has_selector?(".blog_header", text: "#{person.name}, #{person.charge}'s blog")
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
    end
  end
end
