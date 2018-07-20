# frozen_string_literal: true

require "test_helper"
require "support/concerns/user/subscribable_test"
require "support/concerns/gobierto_common/sluggable_test"

module GobiertoPeople
  class PersonPostTest < ActiveSupport::TestCase
    include User::SubscribableTest
    include GobiertoCommon::SluggableTestModule

    def person
      @person ||= gobierto_people_people(:richard)
    end

    def person_post
      @person_post ||= gobierto_people_person_posts(:richard_about_me)
    end
    alias subscribable person_post

    def new_person_post
      ::GobiertoPeople::PersonPost.create!(
        title: "Person Post Title",
        person: gobierto_people_people(:richard),
        site: sites(:madrid)
      )
    end
    alias create_sluggable new_person_post

    def subject_tags
      @subject_tags ||= person_post.tags
    end

    def test_valid
      assert person_post.valid?
    end

    def test_by_tag_scope_with_one_argument
      assert_includes PersonPost.by_tag(subject_tags.first).map(&:id), person_post.id
    end

    def test_by_tag_scope_with_multiple_arguments
      assert_includes PersonPost.by_tag(*subject_tags.first(2)).map(&:id), person_post.id
    end

    def test_by_tag_scope_with_all_arguments
      assert_includes PersonPost.by_tag(*subject_tags).map(&:id), person_post.id
    end

    def test_by_tag_scope_with_all_arguments_but_one
      refute_includes PersonPost.by_tag(*subject_tags.push("wadus")).map(&:id), person_post.id
    end

    def test_public?
      assert person_post.public?

      person.draft!

      refute person_post.public?

      person_post.draft!

      refute person_post.public?

      person.active!

      refute person_post.public?
    end

  end
end
