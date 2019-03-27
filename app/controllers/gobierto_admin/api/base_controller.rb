# frozen_string_literal: true

module GobiertoAdmin
  module Api
    class BaseController < ::GobiertoAdmin::BaseController

      class PayloadError < StandardError; end

      respond_to :json

      rescue_from ActionController::RoutingError,  with: :return_404
      rescue_from ActionController::UnknownFormat, with: :return_404
      rescue_from ActionController::ParameterMissing, with: :return_400

      rescue_from ActiveRecord::RecordNotFound, with: :return_404
      rescue_from ActiveRecord::RecordNotSaved, with: :return_400
      rescue_from ActiveRecord::RecordInvalid,  with: :return_400

      rescue_from PayloadError, with: :return_400

      skip_before_action :verify_authenticity_token

      private

      def return_404
        render json: { error: "not-found" }, status: 404
      end

      def return_400(exception)
        error_message = if exception.respond_to?(:record)
                          exception.record.errors.full_messages.to_sentence
                        else
                          exception.message
                        end
        render json: { error: error_message }, status: 400
      end

    end
  end
end
