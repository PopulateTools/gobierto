module GobiertoAdmin
  module GobiertoBudgetConsultations
    module Consultations
      class ConsultationItemsController < Consultations::BaseController
        before_action :set_consultation, only: [:index, :show, :new, :edit, :create, :update]

        def index
          @consultation_items = @consultation.consultation_items.sorted

          @consultation_form = ConsultationForm.new(
            @consultation.attributes.except(*ignored_consultation_attributes)
          )
          @consultation_visibility_levels = get_consultation_visibility_levels
        end

        def show
          @consultation_item = find_consultation_item
        end

        def new
          @consultation_item_form = ConsultationItemForm.new
          @budget_lines = get_budget_lines
        end

        def edit
          @consultation_item = find_consultation_item
          @consultation_item_form = ConsultationItemForm.new(
            @consultation_item.attributes.except(*ignored_consultation_item_attributes)
          )
          @budget_lines = get_budget_lines
        end

        def create
          @consultation_item_form = ConsultationItemForm.new(
            consultation_item_params.merge(consultation_id: @consultation.id)
          )

          if @consultation_item_form.save
            redirect_to(
              admin_budget_consultation_consultation_items_path(@consultation),
              notice: "Consultation item was successfully created."
            )
          else
            @budget_lines = get_budget_lines
            render :new
          end
        end

        def update
          @consultation_item_form = ConsultationItemForm.new(
            consultation_item_params.merge(id: params[:id])
          )

          if @consultation_item_form.save
            redirect_to(
              admin_budget_consultation_consultation_items_path(@consultation),
              notice: "Consultation item was successfully updated."
            )
          else
            @budget_lines = get_budget_lines
            render :edit
          end
        end

        private

        def find_consultation_item
          @consultation.consultation_items.find(params[:id])
        end

        def set_consultation
          @consultation = find_consultation
        end

        def find_consultation
          current_site.budget_consultations.find(params[:consultation_id])
        end

        def get_budget_lines
          # TODO. Build this collection through TBI API.
          #
          {
            "Pavimentación de vías públicas (10.000 EUR)" => "9208.0/2016-01-01/p/e/f/151"
          }
        end

        def consultation_item_params
          params.require(:consultation_item).permit(
            :title,
            :description,
            :position,
            :budget_line_id
          )
        end

        def ignored_consultation_item_attributes
          %w(
          created_at updated_at
          )
        end
      end
    end
  end
end
