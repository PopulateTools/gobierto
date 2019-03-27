# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class OrderedTermsSortController < BaseController
      def create
        vocabulary.terms.update_parents_and_positions(sort_params)
        head :no_content
      end

      private

      def vocabulary
        @vocabulary ||= current_site.vocabularies.find(params[:vocabulary_id])
      end

      def sort_params
        params.require(:positions).permit!
      end
    end
  end
end
