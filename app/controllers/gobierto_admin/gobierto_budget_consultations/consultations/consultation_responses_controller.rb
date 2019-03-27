# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoBudgetConsultations
    module Consultations
      class ConsultationResponsesController < Consultations::BaseController
        def index
          respond_to do |format|
            format.html
            format.js
          end
        end

        def new
          @consultation_items = find_consultation_items
          @user_genders = get_user_genders
          @consultation_response_form = ConsultationResponseForm.new(consultation_id: @consultation.id, document_number_digest: params[:document_number_digest])
        end

        def create
          @consultation_response_form = ConsultationResponseForm.new(consultation_id: @consultation.id).tap do |c|
            c.assign_attributes(consultation_response_params.except(*ignored_consultation_response_params).merge(
              date_of_birth_year: consultation_response_params["date_of_birth(1i)"],
              date_of_birth_month: consultation_response_params["date_of_birth(2i)"],
              date_of_birth_day: consultation_response_params["date_of_birth(3i)"],
            ))
          end

          if @consultation_response_form.save
            track_create_activity
            redirect_to(edit_admin_budget_consultation_path(@consultation), notice: t(".success"))
          else
            flash[:error] = t(".error")
            @user_genders = get_user_genders
            @consultation_items = find_consultation_items
            render :new
          end
        end

        def show
          respond_to do |format|
            format.html do
              @consultation_response = find_consultation_response
            end
            format.js do
              if @census_item = find_census_item
                @consultation_response = find_consultation_response_by_document_number
              end
            end
          end
        end

        def destroy
          @consultation_response = find_consultation_response
          @consultation_response.destroy
          track_destroy_activity

          respond_to do |format|
            format.html do
              redirect_to edit_admin_budget_consultation_path(@consultation)
            end
            format.js
          end
        end

        private

        def find_consultation_items
          @consultation.consultation_items.sorted
        end

        def consultation_response_params
          params.require(:consultation_response).permit!
        end

        def find_consultation_response
          @consultation.consultation_responses.find(params[:id])
        end

        def find_census_item
          site = @consultation.site
          document_number_digest = ::SecretAttribute.digest(params[:id])
          CensusItem.find_by(document_number_digest: document_number_digest, site_id: site.id)
        end

        def find_consultation_response_by_document_number
          @consultation.consultation_responses.find_by_document_number(params[:id])
        end

        def track_create_activity
          Publishers::GobiertoBudgetConsultationsConsultationResponseActivity.broadcast_event("consultation_response_created", default_activity_params.merge({ subject: @consultation_response_form.consultation_response, recipient: @consultation }))
        end

        def track_destroy_activity
          Publishers::GobiertoBudgetConsultationsConsultationResponseActivity.broadcast_event("consultation_response_deleted", default_activity_params.merge({ subject: @consultation_response, recipient: @consultation }))
        end

        def default_activity_params
          { ip: remote_ip, author: current_admin, site_id: current_site.id }
        end

        def get_user_genders
          User.genders
        end

        def ignored_consultation_response_params
          ["date_of_birth(1i)", "date_of_birth(2i)", "date_of_birth(3i)"]
        end
      end
    end
  end
end
