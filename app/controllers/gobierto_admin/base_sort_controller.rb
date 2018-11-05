# frozen_string_literal: true

module GobiertoAdmin
  class BaseSortController < BaseController
    class NotImplementedError < StandardError; end

    def create
      collection.update_positions(sort_params)
      head :no_content
    end

    private

    def collection
      raise NotImplementedError, "Override this with a method returning an ActiveRecord::Relation of a class with sortable concern"
    end

    def sort_params
      params.require(:positions).permit!
    end
  end
end
