# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoInvestments
    class ProjectForm < BaseForm
      prepend ::GobiertoCommon::TrackableGroupedAttributes

      attr_accessor(
        :id,
        :site_id,
        :title_translations,
        :external_id,
        :admin_id,
        :ip
      )

      validates :site_id, presence: true

      delegate :persisted?, to: :project

      trackable_on :project
      use_event_prefix :project
      notify_changed :title_translations, :external_id, as: :attribute
      use_publisher Publishers::AdminGobiertoInvestmentsActivity
      use_trackable_subject :project

      def save
        save_project if valid?
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      def project
        @project ||= project_class.find_by(id: id).presence || build_project
      end

      private

      def build_project
        project_class.new
      end

      def project_class
        ::GobiertoInvestments::Project
      end

      def save_project
        @project = project.tap do |attributes|
          attributes.site_id = site_id
          attributes.title_translations = title_translations
          attributes.external_id = external_id.blank? ? nil : external_id
        end

        if @project.valid?
          run_callbacks(:save) do
            @project.save
          end

          @project
        else
          promote_errors(@project.errors)

          false
        end
      end

    end
  end
end
