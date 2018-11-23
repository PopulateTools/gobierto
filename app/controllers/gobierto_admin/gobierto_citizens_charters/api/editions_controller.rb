# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    module Api
      class EditionsController < GobiertoCitizensCharters::Api::BaseController
        def index
          find_charter

          reference_edition = @charter.editions.new params.permit(:period, :period_interval)
          @editions = @charter.editions.of_same_period(reference_edition)
          render json: @editions, each_serializer: ::GobiertoAdmin::GobiertoCitizensCharters::EditionSerializer
        end

        def create
          cu_action
        end

        def update
          cu_action extra_params: { id: params[:id] }
        end

        def destroy
          find_charter
          @edition_form = EditionForm.new(id: params[:id], site_id: current_site.id, charter_id: @charter.id, admin_id: current_admin.id)

          if @edition_form.really_destroy!
            render json: { message: "destroyed" }
          else
            render json: { error: "Record couldn't be destroyed" }, status: 400
          end
        end

        protected

        def cu_action(extra_params: {})
          find_charter
          extra_params[:site_id] = current_site.id
          extra_params[:charter_id] = @charter.id
          extra_params[:admin_id] = current_admin.id

          @edition_form = EditionForm.new(edition_params.merge(extra_params))
          if @edition_form.save
            render json: @edition_form.resource, serializer: ::GobiertoAdmin::GobiertoCitizensCharters::EditionSerializer
          else
            raise_invalid_response
          end
        end

        def find_charter
          @charter = current_site.charters.find params[:charter_id]
        end

        def edition_params
          params.permit(
            :commitment_id,
            :period_interval,
            :period,
            :percentage,
            :value,
            :max_value
          )
        end

        def raise_invalid_response
          render json: { error: "Invalid record" }, status: 400
        end
      end
    end
  end
end
