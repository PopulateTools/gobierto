class EncryptCalendarConfigurationCredentials < ActiveRecord::Migration[5.1]

  def self.up
    Site.with_agendas_integration_enabled.each do |site|
      gp_module_settings = site.gobierto_people_settings

      next if gp_module_settings.calendar_integration != 'ibm_notes'

      plain_text_username = gp_module_settings.ibm_notes_usr
      plain_text_password = gp_module_settings.ibm_notes_pwd

      gp_module_settings.ibm_notes_usr = ::SecretAttribute.encrypt(plain_text_username) if plain_text_username.present?
      gp_module_settings.ibm_notes_pwd = ::SecretAttribute.encrypt(plain_text_password) if plain_text_password.present?

      gp_module_settings.save!
    end
  end

  def self.down
    Site.with_agendas_integration_enabled.each do |site|
      gp_module_settings = site.gobierto_people_settings

      next if gp_module_settings.calendar_integration != 'ibm_notes'

      encrypted_username = gp_module_settings.ibm_notes_usr
      encrypted_password = gp_module_settings.ibm_notes_pwd

      gp_module_settings.ibm_notes_usr = ::SecretAttribute.decrypt(encrypted_username) if encrypted_username.present?
      gp_module_settings.ibm_notes_pwd = ::SecretAttribute.decrypt(encrypted_password) if encrypted_password.present?

      gp_module_settings.save!
    end
  end

end
