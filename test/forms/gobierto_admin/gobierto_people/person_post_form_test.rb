# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class PersonPostFormTest < ActiveSupport::TestCase
      def valid_person_post_form
        @valid_person_post_form ||= PersonPostForm.new(
          person_id: person.id,
          title: person_post.title,
          body: person_post.body,
          tags: person_post.tags,
          visibility_level: person.visibility_level
        )
      end

      def invalid_person_post_form
        @invalid_person_post_form ||= PersonPostForm.new(
          person_id: person.id,
          title: nil,
          body: nil,
          tags: []
        )
      end

      def person_post
        @person_post ||= gobierto_people_person_posts(:richard_about_me)
      end

      def person
        @person ||= person_post.person
      end

      def test_save_with_valid_attributes
        assert valid_person_post_form.save
      end

      def test_error_messages_with_invalid_attributes
        invalid_person_post_form.save

        assert_equal 1, invalid_person_post_form.errors.messages[:title].size
      end

      def test_tags_denormalization
        assert_equal person_post.tags.join(", "), valid_person_post_form.tags
      end

      def test_tags_normalization
        valid_person_post_form.tags = "one, two, three"

        assert_equal %w(one two three), valid_person_post_form.tags
      end

      def test_tags_initialization
        valid_person_post_form.tags = nil

        assert_nil valid_person_post_form.tags
      end
    end
  end
end
