module ApplicationHelper
  def render_if_exists(partial_path, partial_params = {}, format = "html.erb")
    partial_path_name = Pathname.new(partial_path)
    partial_file_name = "#{partial_path_name.dirname}/_#{partial_path_name.basename}.#{format}"

    render(partial_path, partial_params) if lookup_context.exists?(partial_file_name)
  end

  def load_module_sub_sections(module_name = nil)
    return unless module_name

    render_if_exists("#{module_name.underscore}/layouts/menu_subsections")
  end
end
