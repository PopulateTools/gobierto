# frozen_string_literal: true

module GobiertoCms
  module PageHelper
    def section_tag(nodes, viewables)
      html = []
      html << "<ul>"
      nodes.each do |node|
        html << "<li>" + link_to(node.item.title, node.item.to_url(section: true,
                                                                   host: current_site.domain))
        if node.children.any? && !(viewables & node.children).empty?
          html << section_tag(node.children, viewables)
        end
        html << "</li>"
      end
      html << "</ul>"
      html.join.html_safe
    end
  end
end
