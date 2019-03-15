# frozen_string_literal: true

module GobiertoCore
  module TemplateHelper
    def template_tree_tag(hash)
      html = []
      html << "<ul>"
      hash.each_pair do |k, v|
        if v.is_a?(Hash) && k != v
          html << "<li><i class='fas fa-folder-open-o'></i>" + k
          html << template_tree_tag(v)
        else
          html << "<li><i class='fas fa-file-o'></i>" +
                  link_to(k, admin_gobierto_core_template_edit_path(::GobiertoCore::Template.where("template_path LIKE ?", "%" + k).first), remote: true) + "</li>"
        end
      end
      html << "</ul>"
      html.join.html_safe
    end
  end
end
