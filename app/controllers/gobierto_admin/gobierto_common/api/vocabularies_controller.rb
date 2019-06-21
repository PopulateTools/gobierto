# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    module Api
      class VocabulariesController < ::GobiertoAdmin::Api::BaseController

        def index
        end

        def show
          load_vocabulary
          render json: ::GobiertoAdmin::GobiertoCommon::VocabularySerializer.new(@vocabulary)
        end

        private

        def load_vocabulary
          @vocabulary = current_site.vocabularies.find(params[:id])
        end

      end
    end
  end
end
