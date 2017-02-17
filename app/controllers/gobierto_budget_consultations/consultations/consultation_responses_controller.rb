module GobiertoBudgetConsultations
  module Consultations
    class ConsultationResponsesController < BaseController
      before_action :authenticate_user!
      before_action { verify_user_in!(current_site) }
      before_action :check_consultation_status

      def new
        @consultation_response_form = ConsultationResponseForm.new(
          user_id: current_user.id,
          consultation_id: @consultation.id
        )

        @consultation_items = @consultation.consultation_items.sorted
      end

      def create
        @consultation_response_form = ConsultationResponseForm.new(
          consultation_response_params.merge(
            user_id: current_user.id,
            consultation_id: @consultation.id
          )
        )

        if @consultation_response_form.save
          respond_to do |format|
            format.html { redirect_to [@consultation, :show_confirmation] }
            format.js
          end
        else
          @consultation_items = @consultation.consultation_items.sorted
          respond_to do |format|
            format.html { render :new }
            format.js
          end
        end
      end

      private

      def consultation_response_params
        params.require(:consultation_response).permit(selected_options: [:item_id, :selected_option])
      end
    end
  end
end
