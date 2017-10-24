# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCms
    class SectionItemsController < BaseController
      def index
        @section = find_section

        render(
          json: { section_items: @section.section_items.map{ |si| default_serializer.new(si) }}
        )
      end

      private

      def default_serializer
        ::GobiertoAdmin::GobiertoCms::SectionItemSerializer
      end

      def find_section
        current_site.sections.find(params[:section_id])
      end
    end
  end
end
