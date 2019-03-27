# frozen_string_literal: true

module GobiertoBudgetConsultations
  module Consultations
    class ConsultationResponsesController < BaseController
      before_action :authenticate_user!
      before_action { verify_user_in!(current_site) }
      before_action :check_consultation_status

      def new
        @consultation_response_form = ConsultationResponseForm.new(
          document_number_digest: document_number_digest,
          consultation_id: @consultation.id,
          user: current_user
        )

        @consultation_items = @consultation.consultation_items.sorted
      end

      def create
        @consultation_response_form = ConsultationResponseForm.new(
          consultation_response_params.merge(
            document_number_digest: document_number_digest,
            consultation_id: @consultation.id,
            user: current_user
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

      def document_number_digest
        @document_number_digest ||= begin
          if user_verification = current_user.site_verification(current_site)
            SecretAttribute.digest(user_verification.verification_data["document_number"])
          end
        end
      end
    end
  end
end
