# frozen_string_literal: true

module GobiertoCms
  module PageHelper
    def section_tree(nodes, viewables)
      html = ["<ul>"]
      nodes.each do |node|
        html << "<li>" + link_to(node.item.title, gobierto_cms_section_item_path(@section.slug, node.item.slug))
        if node.children.any? && !(viewables & node.children).empty?
          html << section_tree(node.children, viewables)
        end
        html << "</li>"
      end
      html << "</ul>"
      html.join.html_safe
    end
  end
end
