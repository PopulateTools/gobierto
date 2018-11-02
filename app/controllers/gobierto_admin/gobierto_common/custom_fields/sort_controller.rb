# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    module CustomFields
      class SortController < BaseSortController

        private

        def collection
          @collection ||= current_site.custom_fields.where(class_name: params[:module_resource_name].tr("-", "/").camelize)
        end
      end
    end
  end
end
