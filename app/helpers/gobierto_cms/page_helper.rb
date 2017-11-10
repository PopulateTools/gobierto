module GobiertoCms
  module PageHelper
    def section_tag(nodes, viewables)
      html = ""
      nodes.each do |node|
        html << "<ul>"
        html << "<li>" + link_to(node.item.title, gobierto_cms_path(node.item.slug, slug_section: node.section.slug))
        if node.children.any? && viewables.include?(node)
          html << section_tag(node.children, node.all_parents)
        end
        html << "</li></ul>"
      end
      return html.html_safe
    end
  end
end
