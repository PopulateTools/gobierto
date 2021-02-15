# frozen_string_literal: true

require "test_helper"
require_relative "base"

module GobiertoPeople
  module People
    class PersonPostShowTest < ActionDispatch::IntegrationTest
      include Base

      def setup
        super
        @path = gobierto_people_person_post_path(person.slug, person_post.slug)
      end

      def site
        @site ||= sites(:madrid)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def person_post
        @person_post ||= gobierto_people_person_posts(:richard_about_me)
      end

      def test_person_post_show
        with_current_site(site) do
          visit @path

          assert has_selector?(".blog_header", text: "#{person.name}, #{person.charge}'s blog")
          assert has_selector?("h1", text: person_post.title)

          Array(person_post.tags).each do |person_post_tag|
            assert has_link?("##{person_post_tag}")
          end

          assert has_content?(person_post.body.html_safe)
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
    end
  end
end
