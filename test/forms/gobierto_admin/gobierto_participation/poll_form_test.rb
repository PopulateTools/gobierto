# frozen_string_literal: true

require "test_helper"
require "support/file_uploader_helpers"

module GobiertoAdmin
  module GobiertoParticipation
    class PollFormTest < ActiveSupport::TestCase

      include FileUploaderHelpers

      def process
        @process ||= gobierto_participation_processes(:commission_for_carnival_festivities)
      end

      def poll
        @poll ||= gobierto_participation_polls(:cycling_tracks_draft)
      end

      def question
        @question ||= gobierto_participation_poll_questions(:cycling_tracks_draft_single_choice)
      end

      def answer_template
        @answer_template ||= gobierto_participation_poll_answer_templates(
          :cycling_tracks_draft_single_choice_answer_template_no
        )
      end

      def answer_template_with_image
        @answer_template_with_image ||= gobierto_participation_poll_answer_templates(
          :cycling_tracks_draft_single_choice_answer_template_yes
        )
      end

      def uploaded_file
        @uploaded_file ||= Rack::Test::UploadedFile.new(
          File.join(
            ActionDispatch::IntegrationTest.fixture_path,
            "files/gobierto_people/people/avatar.jpg"
          )
        )
      end

      def poll_attributes
        {
          process: process,
          title_translations: { I18n.locale => poll.title },
          description_translations: { I18n.locale => poll.description },
          starts_at: poll.starts_at,
          ends_at: poll.ends_at,
          visibility_level: poll.visibility_level,
          visibility_user_level: poll.visibility_user_level,
          questions_attributes: {}
        }
      end

      def question_attributes
        {
          answer_type: "single_choice",
          order: question.order,
          title_translations: question.title_translations,
          answer_templates_attributes: {}
        }
      end

      def answer_template_attributes
        { text: answer_template.text, order: 0 }
      end

      def answer_template_with_image_attributes
        {
          text: answer_template_with_image.text,
          image_file: uploaded_file,
          order: 1
        }
      end

      def valid_poll_form
        poll_form_attributes = poll_attributes.merge(
          questions_attributes: {
            "0" => question_attributes.merge(
              answer_templates_attributes: {
                "0" => answer_template_attributes,
                "1" => answer_template_with_image_attributes
              }
            )
          }
        )
        @valid_poll_form ||= PollForm.new(poll_form_attributes)
      end

      def test_save_valid_poll
        with_stubbed_s3_file_upload do
          assert valid_poll_form.save
        end
      end

      def test_save_invalid_poll
        invalid_poll_form = PollForm.new(
          process: process,
          title_translations: {},
          description_translations: {},
          starts_at: nil,
          ends_at: nil,
          visibility_level: nil,
          visibility_user_level: nil
        )

        with_stubbed_s3_file_upload do
          refute invalid_poll_form.save
        end

        error_keys = invalid_poll_form.errors.keys

        assert error_keys.include?(:title_translations)
        assert error_keys.include?(:starts_at)
        assert error_keys.include?(:ends_at)
      end

      def test_update_answer_template_image
        # create answer templates without image
        poll_form_attributes = poll_attributes.merge(
          questions_attributes: {
            "0" => question_attributes.merge(
              answer_templates_attributes: {
                "0" => { text: "A", order: 0 },
                "1" => { text: "B", order: 1 }
              }
            )
          }
        )

        poll_form = PollForm.new(poll_form_attributes)

        with_stubbed_s3_file_upload do
          assert poll_form.save
        end

        question = poll_form.questions.first
        answer_template_0 = question.answer_templates.first
        answer_template_1 = question.answer_templates.second

        assert_nil answer_template_0.image_url

        # update with the fist image
        poll_form_attributes = poll_attributes.merge(
          id: poll_form.poll.id,
          questions_attributes: {
            "0" => question_attributes.merge(
              id: question.id,
              answer_templates_attributes: {
                "0" => {
                  id: answer_template_0.id,
                  text: "A",
                  order: 0,
                  image_file: uploaded_file
                },
                "1" => { id: answer_template_1.id, text: "B", order: 1 }
              }
            )
          }
        )

        with_stubbed_local_file_upload("http://original.jpg") do
          assert PollForm.new(poll_form_attributes).save
        end

        assert_equal "http://original.jpg", answer_template_0.reload.image_url

        # update with the second image
        with_stubbed_local_file_upload("http://updated.jpg") do
          assert PollForm.new(poll_form_attributes).save
        end

        assert_equal "http://updated.jpg", answer_template_0.reload.image_url

        # update without specifying image
        poll_form_attributes = poll_attributes.merge(
          id: poll_form.poll.id,
          questions_attributes: {
            "0" => question_attributes.merge(
              id: question.id,
              answer_templates_attributes: {
                "0" => { id: answer_template_0.id, text: "A", order: 0 },
                "1" => { id: answer_template_1.id, text: "B", order: 1 }
              }
            )
          }
        )

        assert PollForm.new(poll_form_attributes).save

        assert_equal "http://updated.jpg", answer_template_0.reload.image_url
      end

    end
  end
end
