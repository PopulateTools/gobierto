# frozen_string_literal: true

module GobiertoCommon
  module SortableApi
    extend ActiveSupport::Concern
    # include GobiertoHelper
    included do
      @sortable_attributes_list ||= []
    end

    class_methods do
      def sortable_attributes(*args)
        sortable_attributes_list = @sortable_attributes_list

        sortable_attributes_list |= args

        define_method :sortable_attributes_list do
          sortable_attributes_list
        end

        @sortable_attributes_list = sortable_attributes_list
      end
    end

    def order_params
      return unless params[:order].present?

      params.require(:order).permit(sortable_attributes_list).transform_values { |sort| %w(asc desc).include?(sort) ? sort : "asc" }.to_h
    end
  end
end
