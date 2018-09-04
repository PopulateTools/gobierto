# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoParticipation
    module Processes
      class ProcessStagePagesController < Processes::BaseController
        def new
          @process_stage = find_process_stage
          @process_stage_page_form = ProcessStagePageForm.new(process_stage_id: params[:process_stage_id])
          @process_stage_pages = page_items
          @process_stage_page_selected = nil
        end

        def create
          @process_stage_page_form = ProcessStagePageForm.new(process_stage_page_params.merge(process_stage_id: params[:process_stage_id]))
          @process_stage_pages = page_items

          @process_stage_page_selected = @process_stage_page_form.process_stage_page.page_id

          if @process_stage_page_form.save
            redirect_to edit_admin_participation_process_process_stage_process_stage_page_path(@process_stage_page_form.process_stage_page,
                                                                                               process_id: current_process.id,
                                                                                               process_stage_id: @process_stage_page_form.process_stage_page.process_stage), notice: t(".success")
          else
            render :new
          end
        end

        def edit
          @process_stage = find_process_stage
          load_process_stage_page
          @process_stage_page_form = ProcessStagePageForm.new(
            @process_stage_page.attributes.except(*ignored_process_stage_page_attributes)
          )
          @process_stage_pages = page_items

          @process_stage_page_selected = @process_stage_page_form.process_stage_page.page_id
        end

        def update
          @process_stage_page_form = ProcessStagePageForm.new(process_stage_page_params.merge(id: params[:id], process_stage_id: params[:process_stage_id]))
          @process_stage_pages = page_items

          @process_stage_page_selected = @process_stage_page_form.process_stage_page.page_id

          if @process_stage_page_form.save
            redirect_path = edit_admin_participation_process_process_stage_process_stage_page_path(
              @process_stage_page_form.process_stage_page.parameterize
            )
            redirect_to redirect_path, notice: t(".success")
          else
            render :update
          end
        end

        private

        def find_process_stage
          current_process.stages.find(params[:process_stage_id])
        end

        def load_process_stage_page
          @process_stage_page = @process_stage.process_stage_page
          @preview_item = @process_stage
        end

        def process_stage_page_params
          params.require(:process_stage_page).permit(:page_id)
        end

        def ignored_process_stage_page_attributes
          %w(created_at updated_at process_stage_id)
        end

        def available_pages
          @site.pages.active.sorted
        end

        def page_items
          [[I18n.t("gobierto_admin.sites.pages"), available_pages.map { |p| [p.title, p.id] }]]
        end
      end
    end
  end
end
