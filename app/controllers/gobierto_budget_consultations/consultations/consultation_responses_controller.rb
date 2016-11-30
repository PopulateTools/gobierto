module GobiertoBudgetConsultations
  module Consultations
    class ConsultationResponsesController < BaseController
      before_action :authenticate_user!
      before_action { verify_user_in!(current_site) }
      before_action :check_consultation_status, only: [:new, :create]

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
          redirect_to budget_consultation_show_response_path(@consultation)
        else
          @consultation_items = @consultation.consultation_items.sorted
          render :new
        end
      end

      def show
        @consultation_response = find_consultation_response
      end

      private

      def find_consultation_response
        @consultation.consultation_responses.find_by!(user_id: current_user.id)
      end

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
