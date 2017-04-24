module CalendarIntegrationHelpers
  def activate_calendar_integration(site)
    gp_module_settings = site.module_settings.find_by(module_name: 'GobiertoPeople')

    gp_module_settings.calendar_integration = 'ibm_notes'
    gp_module_settings.ibm_notes_usr = 'username'
    gp_module_settings.ibm_notes_pwd = 'password'

    gp_module_settings.save!
  end
end
