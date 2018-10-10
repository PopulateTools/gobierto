# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    class PollForm < BaseForm

      attr_accessor(
        :id,
        :process,
        :title_translations,
        :description_translations,
        :starts_at,
        :ends_at,
        :visibility_level,
        :questions,
        :visibility_user_level
      )

      delegate(
        :persisted?,
        :editable?,
        :results_available?,
        :unique_answers_count,
        :predicted_unique_answers_count,
        to: :poll
      )

      validates :process, :starts_at, :ends_at, presence: true
      validates(
        :title_translations,
        translated_attribute_presence: true,
        translated_attribute_length: { maximum: 140 }
      )

      def initialize(options = {})
        ordered_options = HashWithIndifferentAccess.new(id: options[:id], process: options[:process])
        ordered_options.merge!(questions_attributes: options[:questions_attributes]) if options[:questions_attributes]
        ordered_options.merge!(options)
        super(ordered_options)
      end

      def save
        save_poll if valid?
      end

      def site
        process.site
      end

      def title
        @title ||= poll.title
      end

      def visibility_level
        @visibility_level ||= 'draft'
      end

      def visibility_user_level
        @visibility_user_level ||= "registered"
      end

      def poll
        @poll ||= (process.polls.find_by(id: id).presence || build_poll)
      end

      def questions
        poll.questions
      end

      def questions_attributes=(attributes)
        attributes.each do |_, question_attributes|

          if question_attributes['id']
            existing_question = poll.questions.detect { |item| item.id == question_attributes['id'].to_i }
          else
            existing_question = nil
          end

          if existing_question && question_attributes[:_destroy] == '1'
            poll.questions.delete(existing_question)
          elsif question_attributes[:_destroy] != '1'

            if existing_question
              question = update_question_from_attributes(existing_question, question_attributes)
            else
              question = build_question_from_attributes(question_attributes)
            end

            answer_templates_attributes = question_attributes[:answer_templates_attributes]
            assign_answer_templates(question, answer_templates_attributes) if answer_templates_attributes
          end
        end

        minify_collection_order(poll.questions)

        poll.questions
      end

      private

      def build_poll
        process.polls.build
      end

      def build_question_from_attributes(attributes)
        poll.questions.build(
          poll: poll, # force poll to be assigned
          answer_type: ::GobiertoParticipation::PollQuestion.answer_types[attributes['answer_type']],
          title_translations: attributes['title_translations'],
          order: attributes['order']
        )
      end

      def update_question_from_attributes(question, attributes)
        question.assign_attributes(
          poll: poll, # force poll to be assigned
          answer_type: ::GobiertoParticipation::PollQuestion.answer_types[attributes['answer_type']],
          title_translations: attributes['title_translations'],
          order: attributes['order']
        )
        question
      end

      def assign_answer_templates(question, answer_templates_attributes)
        answer_templates_attributes.each do |_, answer_template_attributes|

          if answer_template_attributes['id']
            existing_answer_template = question.answer_templates.detect { |item| item.id == answer_template_attributes['id'].to_i }
          else
            existing_answer_template = nil
          end

          if existing_answer_template && answer_template_attributes[:_destroy] == '1'
            question.answer_templates.delete(existing_answer_template)
          elsif answer_template_attributes[:_destroy] != '1'

            if existing_answer_template
              update_answer_template_from_attributes(existing_answer_template, answer_template_attributes)
            else
              build_answer_template_from_attributes(question, answer_template_attributes)
            end

          end
        end

        minify_collection_order(question.answer_templates)
      end

      def build_answer_template_from_attributes(question, attributes)
        question.answer_templates.build(
          question: question, # force question to be assigned
          text: attributes[:text],
          image_url: answer_template_image_url(attributes),
          order: attributes[:order]
        )
      end

      def update_answer_template_from_attributes(answer_template, attributes)
        answer_template.assign_attributes(
          text: attributes[:text],
          image_url: answer_template_image_url(attributes, answer_template),
          order: attributes[:order]
        )
      end

      def save_poll
        @poll = poll.tap do |poll_attributes|
          poll_attributes.process = process
          poll_attributes.title_translations = title_translations
          poll_attributes.description_translations = description_translations
          poll_attributes.starts_at = starts_at
          poll_attributes.ends_at = ends_at
          poll_attributes.visibility_level = visibility_level
          poll_attributes.visibility_user_level = visibility_user_level
          poll_attributes.questions = questions
        end

        if @poll.valid?
          @poll.save
          @poll
        else
          promote_errors(@poll.errors)
          false
        end
      end

      def minify_collection_order(collection)
        order = 0
        collection.sort_by(&:order).each do |collection_item|
          collection_item.order = order
          order += 1
        end
      end

      def answer_template_image_url(attributes, existing_answer_template = nil)
        return existing_answer_template&.image_url unless attributes[:image_file]

        FileUploadService.new(
          site: site,
          collection: ::GobiertoParticipation::PollAnswerTemplate.model_name.collection,
          attribute_name: :image,
          file: attributes[:image_file]
        ).call
      end

    end
  end
end
