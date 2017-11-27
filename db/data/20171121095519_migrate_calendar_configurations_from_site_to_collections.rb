class MigrateCalendarConfigurationsFromSiteToCollections < ActiveRecord::Migration[5.1]

  class MigrationCalendarConfiguration < ApplicationRecord
    self.table_name = :gc_calendar_configurations
  end

  def up
    MigrationCalendarConfiguration.all.each do |calendar_configuration|
      person = ::GobiertoPeople::Person.find(calendar_configuration.person_id)
      site = person.site
      calendar_integration_name = site.gobierto_people_settings.settings['calendar_integration']

      if !valid_calendar_integration_name?(calendar_integration_name)
        puts "[SKIPPING CONFIGURATION] Site #{site.domain} has invalid integration name: #{calendar_integration_name}"
        next
      end

      calendar_configuration_attributes = {
        integration_name: calendar_integration_name,
        collection_id: person.calendar.id,
        person_id: nil,
        data: new_calendar_configuration_data(calendar_configuration, site.gobierto_people_settings)
      }

      print_created_configuration_info(person, site, calendar_configuration_attributes)

      MigrationCalendarConfiguration.create!(calendar_configuration_attributes)
    end

    MigrationCalendarConfiguration.where(collection_id: nil).destroy_all
    clear_residual_calendar_settings_from_sites
  end

  def down
    MigrationCalendarConfiguration.all.each do |cc|
      collection = ::GobiertoCommon::Collection.find(cc.collection_id)
      person = ::GobiertoPeople::Person.find(collection.container_id)
      site = person.site

      restore_site_calendar_configuration(site, cc) unless site.gobierto_people_settings.settings['calendar_integration'].present?

      person_calendar_configuration_attributes = {
        person_id: person.id,
        collection_id: nil,
        data: old_calendar_configuration_data(site.gobierto_people_settings.settings['calendar_integration'], cc)
      }

      print_restore_person_calendar_configuration_info(person, site, person_calendar_configuration_attributes)

      MigrationCalendarConfiguration.create!(person_calendar_configuration_attributes)
    end

    MigrationCalendarConfiguration.where(person_id: nil).destroy_all
  end

  def new_calendar_configuration_data(person_calendar_configuration, gobierto_module_settings)
    invalid_configuration = false
    integration_name = gobierto_module_settings.settings['calendar_integration']

    if integration_name == 'microsoft_exchange'
      data = {
        'microsoft_exchange_usr' => person_calendar_configuration.data['microsoft_exchange_usr'],
        'microsoft_exchange_pwd' => person_calendar_configuration.data['microsoft_exchange_pwd'],
        'microsoft_exchange_url' => person_calendar_configuration.data['microsoft_exchange_url']
      }

      invalid_configuration = (data['microsoft_exchange_usr'].blank? || data['microsoft_exchange_pwd'].blank? || data['microsoft_exchange_url'].blank?)
    elsif integration_name == 'ibm_notes'
      data = {
        'ibm_notes_usr' => ::SecretAttribute.decrypt(gobierto_module_settings.ibm_notes_usr),
        'ibm_notes_pwd' => gobierto_module_settings.ibm_notes_pwd,
        'ibm_notes_url' => person_calendar_configuration.data['endpoint']
      }

      invalid_configuration = (data['ibm_notes_usr'].blank? || data['ibm_notes_pwd'].blank? || data['ibm_notes_url'].blank?)
    elsif integration_name == 'google_calendar'
      data = {
        'calendars'                   => person_calendar_configuration.data['calendars'],
        'google_calendar_id'          => person_calendar_configuration.data['google_calendar_id'],
        'google_calendar_credentials' => person_calendar_configuration.data['google_calendar_credentials']
      }

      invalid_configuration = (data['calendars'].blank? || data['google_calendar_id'].blank? || data['google_calendar_credentials'].blank?)
    end

    raise(Exception, "Invalid configuration for #{integration_name}: #{data}") if invalid_configuration

    return data
  end

  def old_calendar_configuration_data(site_calendar_integration, person_calendar_configuration)
    if (site_calendar_integration == 'microsoft_exchange') || (site_calendar_integration == 'google_calendar')
      person_calendar_configuration.data
    elsif site_calendar_integration == 'ibm_notes'
      { 'endpoint' => person_calendar_configuration.data['ibm_notes_url'] }
    else
      raise Exception
    end
  end

  def restore_site_calendar_configuration(site, person_calendar_configuration)
    gp_settings = site.gobierto_people_settings
    person_calendar_integration_name = person_calendar_configuration.integration_name

    gp_settings.settings.merge!('calendar_integration' => person_calendar_integration_name)

    if person_calendar_integration_name == 'ibm_notes'
      gp_settings.settings.merge!(
        'ibm_notes_usr' => ::SecretAttribute.encrypt(person_calendar_configuration.data['ibm_notes_usr']),
        'ibm_notes_pwd' => person_calendar_configuration.data['ibm_notes_pwd']
      )
    end

    print_restore_site_module_settings_info(gp_settings)

    gp_settings.save!
  end

  def valid_calendar_integration_name?(calendar_integration_name)
    ['ibm_notes', 'microsoft_exchange', 'google_calendar'].include?(calendar_integration_name)
  end

  def clear_residual_calendar_settings_from_sites
    Site.all.each do |site|
      site_gp_settings = site.gobierto_people_settings
      next if site_gp_settings.nil?
      site_gp_settings.settings = site_gp_settings.settings.except(
        'calendar_integration',
        'ibm_notes_usr',
        'ibm_notes_pwd',
        'microsoft_exchange_usr',
        'microsoft_exchange_pwd',
        'microsoft_exchange_url',
        'microsoft_exchange_endpoint'
      )
      site_gp_settings.save!
    end
  end

  def print_created_configuration_info(person, site, person_calendar_configuration_params)
    puts "#{'='*60}"
    puts " * Creating new calendar configuration for #{person.name} from #{site.domain}:\n\n"
    puts JSON.pretty_generate(person_calendar_configuration_params)
    puts "\n\nCalendar ID of #{person.name} is:  #{person.calendar.id}\n\n"
    puts "\n#{'='*60}\n"
  end

  def print_restore_site_module_settings_info(gp_settings)
    puts "#{'='*60}"
    puts " * Restoring GobiertoPeople settings for #{gp_settings.site.domain}:\n\n"
    puts JSON.pretty_generate(gp_settings.attributes)
    puts "\n#{'='*60}\n"
  end

  def print_restore_person_calendar_configuration_info(person, site, person_calendar_configuration_params)
    puts "#{'='*60}"
    puts " * Restoring person calendar configuration for #{person.name} from #{site.domain}:\n\n"
    puts JSON.pretty_generate(person_calendar_configuration_params)
    puts "\n#{'='*60}\n"
  end

end