# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    module Api
      class VocabulariesController < ::GobiertoAdmin::Api::BaseController
        include ::GobiertoCommon::SecuredWithToken

        skip_before_action :authenticate_admin!, :set_admin_with_token
        before_action :set_admin_by_session_or_token

        def index; end

        def show
          load_vocabulary
          render json: @vocabulary, serializer: ::GobiertoAdmin::GobiertoCommon::VocabularySerializer
        end

        private

        def load_vocabulary
          @vocabulary = current_site.vocabularies.find(params[:id])
        end

        def set_admin_by_session_or_token
          set_admin_with_token unless (@current_admin = find_current_admin).present?
        end

      end
    end
  end
end
