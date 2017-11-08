# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    class ProcessInformationForm
      include ActiveModel::Model

      attr_accessor(
        :id,
        :information_text_translations,
        :site_id
      )

      delegate :persisted?, to: :process

      def save
        save_process if valid?
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

      private

      def build_process
        process_class.new
      end

      def process_class
        ::GobiertoParticipation::Process
      end

      def save_process
        @process = process.tap do |process_attributes|
          process_attributes.information_text_translations = information_text_translations
        end

        if @process.valid?
          @process.save

          @process
        else
          promote_errors(@process.errors)

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
