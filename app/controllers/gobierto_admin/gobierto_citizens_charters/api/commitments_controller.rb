# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    module Api
      class CommitmentsController < GobiertoCitizensCharters::Api::BaseController
        def index
          find_charter
          reference_edition = @charter.editions.new params.permit(:period, :period_interval)
          @commitments = @charter.commitments.sorted

          render json: @commitments, each_serializer: ::GobiertoAdmin::GobiertoCitizensCharters::CommitmentSerializer, reference_edition: reference_edition
        end

        protected

        def find_charter
          @charter = current_site.charters.find params[:charter_id]
        end
      end
    end
  end
end
