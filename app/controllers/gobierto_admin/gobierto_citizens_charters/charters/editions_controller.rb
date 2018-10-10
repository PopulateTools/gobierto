# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    module Charters
      class EditionsController < GobiertoCitizensCharters::BaseController
        def index
          @period_interval = ::GobiertoCitizensCharters::Edition.period_intervals.has_key?(params[:period_interval]) ? params[:period_interval] : :year
          @period = params[:period] ? DateTime.parse(params[:period]) : DateTime.current
          @charter = current_site.charters.find(params[:charter_id])
          @reference_edition = ::GobiertoCitizensCharters::Edition.new(period_interval: @period_interval, period: @period)
          @commitments_list = ActiveModelSerializers::SerializableResource.new(
            @charter.commitments,
            each_serializer: GobiertoAdmin::GobiertoCitizensCharters::CommitmentSerializer
          ).serializable_hash
        end
      end
    end
  end
end
