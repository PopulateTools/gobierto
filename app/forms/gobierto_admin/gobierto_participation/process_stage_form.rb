# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    class ProcessStageForm
      include ActiveModel::Model

      attr_accessor(
        :id,
        :process_id,
        :title_translations,
        :description_translations,
        :starts,
        :ends,
        :slug,
        :stage_type,
        :cta_text_translations,
        :menu_translations,
        :cta_description_translations,
        :visibility_level
      )

      delegate :persisted?, to: :process_stage

      def save
        save_process_stage if valid?
      end

      def process_stage
        @process_stage ||= process_stage_class.find_by(id: id).presence || build_process_stage
      end

      def process_id
        @process_id ||= process_stage.process_id
      end

      def process
        @process ||= GobiertoParticipation::Process.find_by(id: process_id)
      end

      def visibility_level
        @visibility_level ||= "draft"
      end

      private

      def build_process_stage
        process_stage_class.new
      end

      def process_stage_class
        ::GobiertoParticipation::ProcessStage
      end

      def save_process_stage
        @process_stage = process_stage.tap do |process_stage_attributes|
          process_stage_attributes.process_id = process_id
          process_stage_attributes.title_translations = title_translations
          process_stage_attributes.description_translations = description_translations
          process_stage_attributes.slug = slug
          process_stage_attributes.starts = starts
          process_stage_attributes.ends = ends
          process_stage_attributes.stage_type = stage_type.to_i
          process_stage_attributes.cta_text_translations = cta_text_translations
          process_stage_attributes.menu_translations = menu_translations
          process_stage_attributes.cta_description_translations = cta_description_translations
          process_stage_attributes.visibility_level = visibility_level
        end

        if @process_stage.valid?
          @process_stage.save
        else
          promote_errors(@process_stage.errors)

          false
        end
      end

      protected

      def promote_errors(errors_hash)
        errors_hash.each do |attribute, message|
          errors.add(attribute, message)
        end
      end
    end
  end
end
