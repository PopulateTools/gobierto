# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    module Processes
      class ProcessStagesController < Processes::BaseController
        def new
          @process_stage_form = ProcessStageForm.new(process_id: current_process.id)
          @stage_types = find_stage_types
          @visibility_levels = find_visibility_levels
          @stage_type_selected = nil

          render(:new_modal, layout: false) && return if request.xhr?
        end

        def edit
          @process_stage = find_process_stage
          @stage_types = find_stage_types
          @stage_type_selected = stage_type_selected
          @visibility_levels = find_visibility_levels

          @process_stage_form = ProcessStageForm.new(
            @process_stage.attributes.except(*ignored_process_stage_attributes)
          )
        end

        def create
          @process_stage_form = ProcessStageForm.new(process_stage_params.merge(process_id: current_process.id))
          @stage_types = find_stage_types
          @visibility_levels = find_visibility_levels

          if @process_stage_form.save
            redirect_to(
              admin_participation_process_process_stages_path(current_process),
              notice: t(".success")
            )
          else
            render :new
          end
        end

        def update
          @process_stage = find_process_stage
          @stage_types = find_stage_types
          @stage_type_selected = stage_type_selected
          @visibility_levels = find_visibility_levels
          @process_stage_form = ProcessStageForm.new(
            process_stage_params.merge(id: params[:id])
          )

          if @process_stage_form.save
            redirect_to(
              admin_participation_process_process_stages_path(current_process),
              notice: t(".success")
            )
          else
            render :edit
          end
        end

        def destroy
          @process_stage = find_process_stage

          respond_to do |format|
            if !@process_stage.active && @process_stage.destroy
              format.js { flash.now[:notice] = t(".success") }
            else
              format.js { flash.now[:alert] = t(".default") }
            end
          end
        end

        private

        def find_stage_types
          stage_types = ::GobiertoParticipation::ProcessStage.stage_types
          stage_types.map { |stage_type| [I18n.t("gobierto_admin.gobierto_participation.processes.process_stages.form.stage_type.#{stage_type.first}"), stage_type.last] }
        end

        def stage_type_selected
          ::GobiertoParticipation::ProcessStage.stage_types[@process_stage.stage_type]
        end

        def find_visibility_levels
          ::GobiertoParticipation::ProcessStage.visibility_levels
        end

        def process_stage_params
          params.require(:process_stage).permit(
            :slug,
            :starts,
            :ends,
            :stage_type,
            :visibility_level,
            menu_translations: [*I18n.available_locales],
            cta_text_translations: [*I18n.available_locales],
            cta_description_translations: [*I18n.available_locales],
            title_translations: [*I18n.available_locales],
            description_translations: [*I18n.available_locales]
          )
        end

        def ignored_process_stage_attributes
          %w(active position created_at updated_at)
        end

        def find_process_stage
          current_process.stages.find(params[:id])
        end
      end
    end
  end
end
