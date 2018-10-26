# frozen_string_literal: true

module GobiertoCms
  class SectionsController < GobiertoCms::ApplicationController
    def show
      section = find_section
      case first_item = section.first_item(only_public: true)
        when GobiertoCms::Page
          redirect_to gobierto_cms_section_item_path(first_item.slug, slug_section: section.slug) and return
        when Module
          redirect_to eval("#{first_item.name.underscore}_root_path") and return
        else
          redirect_to root_path
      end
    end

    private

    def find_section
      current_site.sections.find_by!(slug: params[:slug_section])
    end

  end
end
