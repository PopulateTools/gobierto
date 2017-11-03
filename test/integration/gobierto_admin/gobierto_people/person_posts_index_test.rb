# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_admin/authorizable_resource_test_module"

module GobiertoAdmin
  module GobiertoPeople
    class PersonPostsIndexTest < ActionDispatch::IntegrationTest

      include ::GobiertoAdmin::AuthorizableResourceTestModule

      def setup
        super
        @path = admin_people_person_posts_path(person)
        setup_authorizable_resource_test(gobierto_admin_admins(:steve), @path)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def test_person_posts_index
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "table.person-posts-list tbody" do
              assert has_selector?("tr", count: person.posts.count)

              person.posts.each do |person_post|
                assert has_selector?("tr#person-post-item-#{person_post.id}")

                within "tr#person-post-item-#{person_post.id}" do
                  if person_post.active?
                    assert has_content?("Published")
                  else
                    assert has_content?("Draft")
                  end
                  assert has_link?("View post")
                end
              end
            end
          end
        end
      end
    end
  end
end
