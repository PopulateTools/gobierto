require "test_helper"

module GobiertoPeople
  class PersonPostTest < ActiveSupport::TestCase
    def person_post
      @person_post ||= gobierto_people_person_posts(:richard_about_me)
    end

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
  end
end
