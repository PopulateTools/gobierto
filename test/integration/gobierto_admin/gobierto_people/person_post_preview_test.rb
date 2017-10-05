# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_admin/authorizable_resource_preview_test_module"

module GobiertoAdmin
  module GobiertoPeople
    class PersonPostPreviewTest < ActionDispatch::IntegrationTest

      include ::GobiertoAdmin::AuthorizableResourcePreviewTestModule

      def setup
        super
        @path = admin_people_person_posts_path(richard)
        setup_authorizable_resource_preview_test(
          gobierto_admin_admins(:steve),
          gobierto_people_person_post_path(richard.slug, active_post.slug),
          gobierto_people_person_post_path(richard.slug, draft_post.slug),
          richard
        )
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def richard
        gobierto_people_people(:richard)
      end

      def site
        @site ||= sites(:madrid)
      end

      def active_post
        richard.posts.active.first
      end

      def draft_post
        richard.posts.draft.first
      end

      def test_preview_active_person_active_post
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "tr#person-post-item-#{active_post.id}" do
              preview_link = find("a", text: "View post")

              refute preview_link[:href].include?(admin.preview_token)

              preview_link.click
            end

            assert_equal gobierto_people_person_post_path(active_post.person.slug, active_post.slug), current_path
            assert has_selector?("h1", text: active_post.title)
          end
        end
      end

      def test_preview_active_person_draft_post_as_admin
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "tr#person-post-item-#{draft_post.id}" do
              preview_link = find("a", text: "View post")

              assert preview_link[:href].include?(admin.preview_token)

              preview_link.click
            end

            assert_equal gobierto_people_person_post_path(draft_post.person.slug, draft_post.slug), current_path
            assert has_selector?("h1", text: draft_post.title)
          end
        end
      end

      def test_preview_draft_person_active_post
        draft_post.person.draft!

        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "tr#person-post-item-#{active_post.id}" do
              preview_link = find("a", text: "View post")

              assert preview_link[:href].include?(admin.preview_token)

              preview_link.click
            end

            assert_equal gobierto_people_person_post_path(active_post.person.slug, active_post.slug), current_path
            assert has_selector?("h1", text: active_post.title)
          end
        end
      end

      def test_preview_draft_person_draft_post_as_admin
        draft_post.person.draft!

        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "tr#person-post-item-#{draft_post.id}" do
              preview_link = find("a", text: "View post")

              assert preview_link[:href].include?(admin.preview_token)

              preview_link.click
            end

            assert_equal gobierto_people_person_post_path(draft_post.person.slug, draft_post.slug), current_path
            assert has_selector?("h1", text: draft_post.title)
          end
        end
      end

      def test_preview_draft_post_if_not_admin
        with_current_site(site) do
          assert_raises ActiveRecord::RecordNotFound do
            visit gobierto_people_person_post_path(draft_post.person.slug, draft_post.slug)
          end

          refute has_selector?("h1", text: draft_post.title)

          draft_post.person.draft!

          assert_raises ActiveRecord::RecordNotFound do
            visit gobierto_people_person_post_path(draft_post.person.slug, draft_post.slug)
          end

          refute has_selector?("h1", text: draft_post.title)
        end
      end
    end
  end
end
