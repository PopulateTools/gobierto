# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class OrderedTermsSortController < BaseController
      def create
        vocabulary.terms.update_positions(issue_sort_params)
        head :no_content
      end

      private

      def vocabulary
        @vocabulary ||= begin
                          vocabulary_id = params[:vocabulary_id]
                          current_site.vocabularies.find(vocabulary_id)
                        end
      end

      def issue_sort_params
        params.require(:positions).permit!
      end
    end
  end
end
