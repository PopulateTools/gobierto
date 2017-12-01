module SubmodulesHelper
  extend ActiveSupport::Concern

  included do
    helper_method :active_submodules, :welcome_submodule_active?, :officials_submodule_active?,
                  :agendas_submodule_active?, :blog_submodule_active?, :statements_submodule_active?,
                  :submodule_path_for, :submodule_title_for, :submodule_controller_for,
                  :budgets_elaboration_active?,
                  :budget_lines_feedback_active?, :gobierto_budgets_feedback_emails,
                  :budgets_receipt_active?, :budgets_receipt_configuration, :submodule_has_content?,
                  :budgets_comparison_context_table_enabled, :budgets_comparison_compare_municipalities, :budgets_comparison_show_widget
  end

  private

  def budgets_elaboration_active?
    current_site.gobierto_budgets_settings && current_site.gobierto_budgets_settings.settings["budgets_elaboration"]
  end

  def budget_lines_feedback_active?
    current_site.gobierto_budgets_settings && current_site.gobierto_budgets_settings.settings["budget_lines_feedback_enabled"]
  end

  def gobierto_budgets_feedback_emails
    current_site.gobierto_budgets_settings && current_site.gobierto_budgets_settings.settings["feedback_emails"]
  end

  def budgets_receipt_active?
    current_site.gobierto_budgets_settings && current_site.gobierto_budgets_settings.settings["budgets_receipt_enabled"]
  end

  def budgets_receipt_configuration
    current_site.gobierto_budgets_settings && current_site.gobierto_budgets_settings.settings["budgets_receipt_configuration"]
  end

  def budgets_comparison_context_table_enabled
    current_site.gobierto_budgets_settings && current_site.gobierto_budgets_settings.settings["comparison_context_table_enabled"]
  end

  def budgets_comparison_compare_municipalities
    current_site.gobierto_budgets_settings && current_site.gobierto_budgets_settings.settings["comparison_compare_municipalities"] || []
  end

  def budgets_comparison_show_widget
    current_site.gobierto_budgets_settings && current_site.gobierto_budgets_settings.settings["comparison_show_widget"]
  end

  def available_submodules
    {
      officials: {
        root_path: gobierto_people_people_path,
        layout_title: t('gobierto_people.layouts.menu_subsections.people'),
        controller_name: 'people'
      },
      agendas: {
        root_path: gobierto_people_events_path,
        layout_title: t('gobierto_people.layouts.menu_subsections.agendas'),
        controller_name: 'person_events'
      },
      blogs: {
        root_path: gobierto_people_posts_path,
        layout_title: t('gobierto_people.layouts.menu_subsections.blogs'),
        controller_name: 'person_posts'
      },
      statements: {
        root_path: gobierto_people_statements_path,
        layout_title: t('gobierto_people.layouts.menu_subsections.statements'),
        controller_name: 'person_statements'
      }
    }
  end

  def active_submodules
    if current_site.gobierto_people_settings
      current_site.gobierto_people_settings.submodules_enabled
    else
      GobiertoPeople.module_submodules
    end
  end

  def welcome_submodule_active?
    active_submodules.size > 1
  end

  def officials_submodule_active?
    active_submodules.include?('officials')
  end

  def agendas_submodule_active?
    active_submodules.include?('agendas')
  end

  def blog_submodule_active?
    active_submodules.include?('blogs')
  end

  def statements_submodule_active?
    active_submodules.include?('statements')
  end

  def submodule_path_for(submodule)
    available_submodules[submodule.to_sym][:root_path]
  end

  def submodule_title_for(submodule)
    available_submodules[submodule.to_sym][:layout_title]
  end

  def submodule_controller_for(submodule)
    available_submodules[submodule.to_sym][:controller_name]
  end

  def submodule_has_content?(submodule)
    if submodule == 'blogs'
      return current_site.person_posts.active.any?
    end
    return true
  end
end
