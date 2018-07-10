module GobiertoCms
  module GlobalNavigation
    extend ActiveSupport::Concern

    included do
      helper_method :global_navigation_section?, :global_navigation_section
    end

    private

    def global_navigation_section?
      global_navigation_section.present?
    end

    def global_navigation_section
      @global_navigation_section ||= current_site.sections.find_by(slug: 'global-navigation')
    end

  end
end
