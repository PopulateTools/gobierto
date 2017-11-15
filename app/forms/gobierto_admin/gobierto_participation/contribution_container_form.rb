# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    class ContributionContainerForm
      include ActiveModel::Model

      attr_accessor(
        :id,
        :admin_id,
        :site_id,
        :process_id,
        :title_translations,
        :description_translations,
        :starts,
        :ends,
        :contribution_type,
        :visibility_level,
        :visibility_user_level
      )

      delegate :persisted?, to: :contribution_container

      validates :title_translations, :description_translations, presence: true
      validates :admin_id, :site, presence: true

      def save
        save_contribution_container if valid?
      end

      def contribution_container
        @contribution_container ||= contribution_container_class.find_by(id: id).presence || build_contribution_container
      end

      def site_id
        @site_id ||= contribution_container.site_id
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      def visibility_level
        @visibility_level ||= "draft"
      end

      def visibility_user_level
        @visibility_user_level ||= "registered"
      end

      def contribution_type
        @contribution_type ||= "idea"
      end

      private

      def build_contribution_container
        contribution_container_class.new
      end

      def contribution_container_class
        ::GobiertoParticipation::ContributionContainer
      end

      def save_contribution_container
        @contribution_container = contribution_container.tap do |contribution_container_attributes|
          contribution_container_attributes.admin_id = admin_id
          contribution_container_attributes.site_id = site_id
          contribution_container_attributes.process_id = process_id
          contribution_container_attributes.title_translations = title_translations
          contribution_container_attributes.description_translations = description_translations
          contribution_container_attributes.starts = starts
          contribution_container_attributes.ends = ends
          contribution_container_attributes.contribution_type = contribution_type
          contribution_container_attributes.visibility_level = visibility_level
          contribution_container_attributes.visibility_user_level = visibility_user_level
        end

        if @contribution_container.valid?
          @contribution_container.save

          @contribution_container
        else
          promote_errors(@contribution_container.errors)

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
