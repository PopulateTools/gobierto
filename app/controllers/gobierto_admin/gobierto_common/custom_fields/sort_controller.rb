# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    module CustomFields
      class SortController < BaseSortController

        private

        def collection
          @collection ||= begin
                            return current_site.custom_fields.none unless ["localized", "not_localized"].any?(params[:localized])

                            current_site.custom_fields.where(class_name: params[:module_resource_name].tr("-", "/").camelize).send(params[:localized])
                          end
        end
      end
    end
  end
end
