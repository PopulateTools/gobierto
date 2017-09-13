module GobiertoParticipation
  module Processes
    class PollAnswerForm

      attr_reader :poll, :user, :questions_attributes, :answers_attributes

      def initialize(params = {})
        @poll = params[:poll]
        @user = params[:user]
        if params[:questions_attributes]
          process_answer_templates_attributes(params)
        end
      end

      def poll_title
        poll.title
      end

      def questions
        poll.questions
      end

      # Useless method, needed for fields_for :questions
      def questions_attributes=
      end

      def save
        ActiveRecord::Base.transaction do
          PollAnswer.create!(answers_attributes)
        end
        true
      rescue
        false
      end

      private

      def process_answer_templates_attributes(params)
        @answers_attributes = []

        params[:questions_attributes].each do |_, answer_attrs_wrapper|

          question = PollQuestion.find(answer_attrs_wrapper[:id])

          answer_attributes = {
            poll_id: question.poll.id,
            question_id: question.id,
            user_id: user.id
          }

          answer_attrs_wrapper[:answers_attributes].each do |_, answer_attrs|
            @answers_attributes << answer_attributes.merge(
              answer_template_id: answer_attrs[:answer_template_id],
              text: answer_attrs[:text]
            )
          end

        end
      end

    end
  end
end
