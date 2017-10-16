# frozen_string_literal: true

module CalendarIntegrationHelpers

  def activate_ibm_notes_calendar_integration(site)
    gp_module_settings = site.gobierto_people_settings

    gp_module_settings.calendar_integration = 'ibm_notes'
    gp_module_settings.ibm_notes_usr = ::SecretAttribute.encrypt('username')
    gp_module_settings.ibm_notes_pwd = ::SecretAttribute.encrypt('password')

    gp_module_settings.save!
  end

  def activate_google_calendar_calendar_integration(site)
    gp_module_settings = site.gobierto_people_settings
    gp_module_settings.calendar_integration = 'google_calendar'
    gp_module_settings.save!
  end

  def set_ibm_notes_calendar_endpoint(person, endpoint)
    calendar_conf = person.calendar_configuration
    calendar_conf.data = { endpoint: endpoint }
    calendar_conf.save!
  end

  def configure_google_calendar_integration(person, options)
    calendar_conf = person.calendar_configuration
    calendar_conf.data = options
    calendar_conf.save!
  end

  def remove_ibm_notes_calendar_integration(site)
    gp_module_settings = site.gobierto_people_settings

    gp_module_settings.calendar_integration = nil
    gp_module_settings.ibm_notes_usr = nil
    gp_module_settings.ibm_notes_pwd = nil

    gp_module_settings.save!
  end

end
