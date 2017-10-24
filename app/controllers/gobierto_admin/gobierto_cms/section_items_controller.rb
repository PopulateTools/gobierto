# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCms
    class SectionItemsController < BaseController
      def create
        @section_item_form = SectionItemForm.new(section_id: params[:section_id],
                                                 item_type: "GobiertoCms::Page",
                                                 item_id: params[:page_id],
                                                 parent_id: 0)

        if @section_item_form.save
          # track_create_activity
        end

      end

      def index
        @section = find_section

        render(
          json: { section_items: @section.section_items.map{ |si| default_serializer.new(si) }}
        )
      end

      private

      # def track_create_activity
      #   Publishers::IssueActivity.broadcast_event("issue_created", default_activity_params.merge(subject: @issue_form.issue))
      # end
      #
      # def track_update_activity
      #   Publishers::IssueActivity.broadcast_event("issue_updated", default_activity_params.merge(subject: @issue))
      # end

      def default_activity_params
        { ip: remote_ip, author: current_admin, site_id: current_site.id }
      end

      def ignored_issue_attributes
        %w(position created_at updated_at)
      end

      def default_serializer
        ::GobiertoAdmin::GobiertoCms::SectionItemSerializer
      end

      def find_section
        current_site.sections.find(params[:section_id])
      end
    end
  end
end
