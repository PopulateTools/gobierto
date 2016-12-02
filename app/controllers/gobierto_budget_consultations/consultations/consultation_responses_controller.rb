module GobiertoBudgetConsultations
  module Consultations
    class ConsultationResponsesController < BaseController
      before_action :authenticate_user!
      before_action { verify_user_in!(current_site) }
      before_action :check_consultation_status

      def new
        @consultation_response_form = ConsultationResponseForm.new
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
          redirect_to budget_consultation_new_confirmation_path(@consultation)
        else
          @consultation_items = @consultation.consultation_items.sorted
          render :new
        end
      end

      private

      def consultation_response_params
        # TODO. Implement support for arbitrary hashes in strong parameters.
        # Take this commit as a reference:
        # https://github.com/rails/rails/commit/e86524c0c5a26ceec92895c830d1355ae47a7034
        #
        params.require(:consultation_response).permit!
      end
    end
  end
end
