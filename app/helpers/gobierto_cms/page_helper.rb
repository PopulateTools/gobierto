module GobiertoCms
  module PageHelper
    def section_tag(nodes, viewables)
      html = ""
      nodes.each do |node|
        html << "<ul>"
        html << "<li>" + link_to(node.item.title, node.item.to_url(section: true))
        if node.children.any? && !(viewables & node.children).empty?
          html << section_tag(node.children, viewables)
        end
        html << "</li></ul>"
      end
      html.html_safe
    end
  end
end
