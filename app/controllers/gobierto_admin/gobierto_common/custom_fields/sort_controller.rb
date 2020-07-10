# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    module CustomFields
      class SortController < BaseSortController

        def create
          collection.update_positions(sort_params)
          touch_instances
          head :no_content
        end

        private

        def collection
          @collection ||= begin
                            return current_site.custom_fields.none unless ["localized", "not_localized"].any?(params[:localized])

                            current_site.custom_fields.where(class_name: params[:module_resource_name].tr("-", "/").camelize).send(params[:localized])
                          end
        end

        def touch_instances
          field_ids = params[:positions].values.map { |item| item["id"] }
          instances = collection.where.not(instance: nil).where(id: field_ids).select(:instance_id, :instance_type).distinct.map(&:instance)
          instances.each(&:touch)
        end
      end
    end
  end
end
