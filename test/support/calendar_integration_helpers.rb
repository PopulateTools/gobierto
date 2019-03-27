# frozen_string_literal: true

module CalendarIntegrationHelpers

  ## Common

  def clear_calendar_configurations
    ::GobiertoCalendars::CalendarConfiguration.all.destroy_all
  end

  ## IBM Notes

  def configure_ibm_notes_calendar_integration(params)
    collection = params[:collection]
    data = params[:data]
    calendar_conf = collection.calendar_configuration || collection.build_calendar_configuration

    calendar_conf.data = params[:data].merge({
      ibm_notes_pwd: SecretAttribute.encrypt(data[:ibm_notes_pwd]),
    })
    calendar_conf.integration_name = "ibm_notes"
    calendar_conf.save!
  end

  ## Google Calendar

  def configure_google_calendar_integration(params)
    collection = params[:collection]
    data = params[:data]
    calendar_conf = collection.calendar_configuration || collection.build_calendar_configuration

    calendar_conf.data = params[:data]
    calendar_conf.integration_name = "google_calendar"
    calendar_conf.save!
  end

  # Microsoft Exchange

  def configure_microsoft_exchange_calendar_integration(params)
    collection = params[:collection]
    data = params[:data]
    calendar_conf = collection.calendar_configuration || collection.build_calendar_configuration

    calendar_conf.data = params[:data].merge({
      microsoft_exchange_pwd: SecretAttribute.encrypt(data[:microsoft_exchange_pwd]),
    })
    calendar_conf.integration_name = "microsoft_exchange"
    calendar_conf.save!
  end

end
