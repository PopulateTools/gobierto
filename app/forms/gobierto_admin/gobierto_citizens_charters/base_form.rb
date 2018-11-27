# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    class BaseForm < ::BaseForm
      class NotImplementedError < StandardError; end
      prepend ::GobiertoCommon::TrackableGroupedAttributes

      attr_accessor :id, :site_id, :admin_id
      attr_writer(
        :visibility_level
      )

      validates :site, presence: true
      delegate :persisted?, to: :resource

      def resource
        @resource ||= resources_relation.find_by(id: id) || build_resource
      end

      def build_resource
        resources_relation.new
      end

      def visibility_level
        @visibility_level ||= "draft"
      end

      def save
        save_resource if valid?
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      def destroy
        destroy_resource
      end

      def really_destroy!
        really_destroy_resource
      end

      def available_visibility_levels
        resources_relation.try(:visibility_levels)
      end

      def notify?
        !resource.respond_to?(:active?) || resource.active?
      end

      private

      def save_resource
        @resource = resource.tap do |attributes|
          attributes.assign_attributes(visibility_level: visibility_level) if attributes.has_attribute? :visibility_level
          attributes.assign_attributes(attributes_assignments) if respond_to? :attributes_assignments
          attributes.admin_id = admin_id
        end

        if @resource.valid?
          if @resource.changes.any?

            run_callbacks(:save) do
              @resource.save
            end
          end
          @resource
        else
          promote_errors(@resource.errors)
          false
        end
      end

      def destroy_resource
        resource.admin_id = admin_id
        run_callbacks(:destroy) do
          resource.destroy
        end
      end

      def really_destroy_resource
        resource.admin_id = admin_id
        run_callbacks(:destroy) do
          resource.really_destroy!
        end
      end

      def resources_relation
        raise NotImplementedError, "Override this with a method returning an ActiveRecord::Relation"
      end
    end
  end
end
