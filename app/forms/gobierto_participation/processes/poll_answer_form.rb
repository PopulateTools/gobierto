# frozen_string_literal: true

module GobiertoParticipation
  module Processes
    class PollAnswerForm

      attr_reader :poll, :user, :questions_attributes, :answers_attributes

      class InvalidAnswerSet < StandardError; end

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

      def questions_count
        questions.count
      end

      # Useless method, needed for fields_for :questions
      def questions_attributes=
      end

      def save
        return false unless valid?

        ActiveRecord::Base.transaction do
          PollAnswer.create!(answers_attributes)
        end
        true
      rescue ActiveRecord::Rollback
        false
      end

      def valid?
        user.present? && poll.answerable_by?(user) && answers_for_all_questions?
      end

      private

      def process_answer_templates_attributes(params)
        @answers_attributes = []

        params[:questions_attributes].each do |_, answer_attrs_wrapper|

          question = PollQuestion.find(answer_attrs_wrapper[:id])

          next if question.nil? || user.nil? || answer_attrs_wrapper[:answers_attributes].nil?

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

      def answers_for_all_questions?
        question_ids = answers_attributes.map{ |answer| answer[:question_id] }.uniq.sort
        question_ids == questions.map{ |q| q.id }.sort
      end

    end
  end
end
