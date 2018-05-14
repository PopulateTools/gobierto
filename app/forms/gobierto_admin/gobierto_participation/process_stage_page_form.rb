# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    class ProcessStagePageForm < BaseForm

      attr_writer :site_id, :process_stage_id
      attr_accessor :id, :page_id

      delegate :persisted?, :process_stage, to: :process_stage_page

      def save
        save_process_stage_page if valid?
      end

      def process
        @process ||= process_class.find_by(id: id).presence || build_process
      end

      def site_id
        @site_id ||= process.site_id
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      def process_stage_page
        @process_stage_page ||= process_stage_page_class.find_by(id: id).presence || build_process_stage_page
      end

      def process_stage_id
        @process_stage_id ||= process_stage.id
      end

      private

      def build_process_stage_page
        process_stage_page_class.new
      end

      def process_stage_page_class
        ::GobiertoParticipation::ProcessStagePage
      end

      def save_process_stage_page
        @process_stage_page = process_stage_page.tap do |process_stage_page_attributes|
          process_stage_page_attributes.page_id = page_id
          process_stage_page_attributes.process_stage_id = process_stage_id
        end

        if @process_stage_page.valid?
          @process_stage_page.save

          @process_stage_page
        else
          promote_errors(@process_stage_page.errors)

          false
        end
      end

    end
  end
end
