# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoBudgetConsultations
    module Consultations
      class ConsultationItemsController < Consultations::BaseController
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

          render :new_modal, layout: false and return if request.xhr?
        end

        def edit
          @consultation_item = find_consultation_item
          @consultation_item_form = ConsultationItemForm.new(
            @consultation_item.attributes.except(*ignored_consultation_item_attributes)
          )
          @budget_lines = get_budget_lines

          render :edit_modal, layout: false and return if request.xhr?
        end

        def create
          @consultation_item_form = ConsultationItemForm.new(
            consultation_item_params.merge(consultation_id: @consultation.id)
          )

          if @consultation_item_form.save
            redirect_to(
              admin_budget_consultation_consultation_items_path(@consultation),
              notice: t(".success")
            )
          else
            @budget_lines = get_budget_lines
            render :new_modal, layout: false and return if request.xhr?
            render :new
          end
        end

        def update
          @consultation_item = find_consultation_item
          @consultation_item_form = ConsultationItemForm.new(
            consultation_item_params.merge(id: params[:id])
          )

          if @consultation_item_form.save
            redirect_to(
              admin_budget_consultation_consultation_items_path(@consultation),
              notice: t(".success")
            )
          else
            @budget_lines = get_budget_lines
            render :edit_modal, layout: false and return if request.xhr?
            render :edit
          end
        end

        private

        def find_consultation_item
          @consultation.consultation_items.find(params[:id])
        end

        def get_budget_lines
          BudgetLineCollectionBuilder.new(current_site).call
        end

        def consultation_item_params
          params.require(:consultation_item).permit(
            :title,
            :description,
            :position,
            :budget_line_id,
            :budget_line_name,
            :budget_line_amount,
            :block_reduction
          )
        end

        def ignored_consultation_item_attributes
          %w(created_at updated_at)
        end
      end
    end
  end
end
