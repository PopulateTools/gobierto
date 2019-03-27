# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  module Processes
    class PollAnswerFormTest < ActiveSupport::TestCase

      def poll_answers_params
        @poll_answers_params ||= {
          questions_attributes: {
            "0" => {
              id: "929669461",
              answers_attributes: {
                "0" => {
                  answer_template_id: "373102810"
                }
              }
            },
            "1" => {
              id: "803812805",
              answers_attributes: {
                "0" => {
                  answer_template_id: "611765973"
                }
              }
            },
            "2" => {
              id: "84785086",
              answers_attributes: {
                "0" => {
                  text: ""
                }
              }
            }
          }
        }.with_indifferent_access
      end

      def poll_incomplete_answers_params
        @poll_incomplete_answers_params = poll_answers_params
        @poll_incomplete_answers_params[:questions_attributes].delete("1")
        @poll_incomplete_answers_params
      end

      def process
        @process ||= gobierto_participation_processes(:commission_for_carnival_festivities)
      end

      def poll
        @poll ||= gobierto_participation_polls(:ordinance_of_terraces_published)
      end

      def past_poll
        @past_poll ||= gobierto_participation_polls(:noise_problems_past)
      end

      def user
        @user ||= users(:peter)
      end

      def user_already_answered
        @user_already_answered ||= users(:dennis)
      end

      def test_initialize_with_valid_parameters
        poll_answer = PollAnswerForm.new(poll: poll)

        assert_equal "General aspects of the ordinance", poll_answer.poll_title
        assert_equal 3, poll_answer.questions_count
      end

      def test_valid?
        valid_poll_answer  = PollAnswerForm.new(poll_answers_params.merge(user: user, poll: poll))
        without_user       = PollAnswerForm.new(poll_answers_params.merge(poll: poll))
        already_answered   = PollAnswerForm.new(poll_answers_params.merge(user: user_already_answered, poll: poll))
        closed_poll        = PollAnswerForm.new(poll_answers_params.merge(user: user, poll: past_poll))
        incomplete_answers = PollAnswerForm.new(poll_incomplete_answers_params.merge(user: user, poll: poll))

        assert valid_poll_answer.valid?
        refute without_user.valid?
        refute already_answered.valid?
        refute closed_poll.valid?
        refute incomplete_answers.valid?
      end

      def test_save_demographic_info
        poll_answer_form = PollAnswerForm.new(poll_answers_params.merge(
          user: user,
          poll: poll
        ))

        poll_answer_form.save

        answers = poll.answers.by_user(user)
        meta_info = SecretAttribute.decrypt(answers.first.encrypted_meta)
        expected_meta_info = {
          gender: 0,
          birthdate: user.date_of_birth.iso8601,
          age: user.age,
          district: "Retiro"
        }

        assert_equal expected_meta_info, meta_info
      end

    end
  end
end
