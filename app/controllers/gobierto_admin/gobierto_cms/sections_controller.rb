# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCms
    class SectionsController < BaseController
      def index
        @sections = current_site.sections

        @section_form = SectionForm.new(site_id: current_site.id)
      end

      def show
        @section = find_section
        @pages = ::GobiertoCms::Page.pages_in_collections(current_site).active.uniq
      end

      def pages
        @pages = ::GobiertoCms::Page.pages_in_collections(current_site).search(params[:query]).uniq

        respond_to do |format|
          format.js {render layout: false}
        end
      end

      def new
        @section_form = SectionForm.new

        render(:new_modal, layout: false) && return if request.xhr?
      end

      def edit
        @section = find_section
        @section_form = SectionForm.new(
          @section.attributes.except(*ignored_section_attributes)
        )

        render(:edit_modal, layout: false) && return if request.xhr?
      end

      def create
        @section_form = SectionForm.new(section_params.merge(site_id: current_site.id))

        if @section_form.save
          track_create_activity

          redirect_to(
            admin_cms_section_path(@section_form.section),
            notice: t(".success_html", link: "gobierto_participation_section_url(@section_form.section.slug, host: current_site.domain)")
          )
        else
          render(:new_modal, layout: false) && return if request.xhr?
          render :new
        end
      end

      def update
        @section = find_section
        @section_form = SectionForm.new(
          section_params.merge(id: params[:id])
        )

        if @section_form.save
          track_update_activity

          redirect_to(
            admin_cms_section_path(@section_form.section),
            notice: t(".success_html", link: "gobierto_participation_section_url(@section_form.section.slug, host: current_site.domain)")
          )
        else
          render(:edit_modal, layout: false) && return if request.xhr?
          render :edit
        end
      end

      private

      def track_create_activity
        Publishers::GobiertoCmsSectionActivity.broadcast_event("section_created", default_activity_params.merge(subject: @section_form.section))
      end

      def track_update_activity
        Publishers::GobiertoCmsSectionActivity.broadcast_event("section_updated", default_activity_params.merge(subject: @section))
      end

      def default_activity_params
        { ip: remote_ip, author: current_admin, site_id: current_site.id }
      end

      def section_params
        params.require(:section).permit(
          :slug,
          title_translations: [*I18n.available_locales]
        )
      end

      def ignored_section_attributes
        %w(created_at updated_at)
      end

      def find_section
        current_site.sections.find(params[:id])
      end
    end
  end
end
