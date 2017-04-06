module SubmodulesHelper
  extend ActiveSupport::Concern

  included do
    helper_method :active_submodules, :welcome_submodule_active?, :officials_submodule_active?, :agendas_submodule_active?, :blog_submodule_active?, :statements_submodule_active?, :submodule_path_for, :submodule_title_for, :submodule_controller_for
  end

  private

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
      blog: {
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
    active_submodules = GobiertoPeople::Setting.where("key ~* ?", ".*_submodule_active").where(value: 'true', site: current_site)
    active_submodules_names = active_submodules.pluck(:key).map { |key| key.gsub("_submodule_active", "") }
    active_submodules_names & available_submodules.keys.map(&:to_s)
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
    active_submodules.include?('blog')
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

end
