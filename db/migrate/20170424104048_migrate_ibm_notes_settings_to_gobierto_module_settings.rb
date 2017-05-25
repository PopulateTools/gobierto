# frozen_string_literal: true

class MigrateIbmNotesSettingsToGobiertoModuleSettings < ActiveRecord::Migration[5.0]
  def migrate_ibm_notes_users
    ibm_notes_users_settings = GobiertoPeople::Setting.where(key: 'IBM_NOTES_ENDPOINT_USR')

    ibm_notes_users_settings.each do |setting|
      gobierto_module_settings = GobiertoModuleSettings.find_or_create_by(
        site: setting.site,
        module_name: 'GobiertoPeople'
      )

      gobierto_module_settings.ibm_notes_usr = setting.value
      gobierto_module_settings.save!
    end

    ibm_notes_users_settings.destroy_all
  end

  def migrate_ibm_notes_passwords
    ibm_notes_pwd_settings = GobiertoPeople::Setting.where(key: 'IBM_NOTES_ENDPOINT_PWD')

    ibm_notes_pwd_settings.each do |setting|
      gobierto_module_settings = GobiertoModuleSettings.find_or_create_by(
        site: setting.site,
        module_name: 'GobiertoPeople'
      )

      gobierto_module_settings.ibm_notes_pwd = setting.value
      gobierto_module_settings.save!
    end

    ibm_notes_pwd_settings.destroy_all
  end

  def up
    migrate_ibm_notes_users
    migrate_ibm_notes_passwords
  end

  def down
    GobiertoModuleSettings.where(module_name: 'GobiertoPeople').each do |module_settings|
      if module_settings.settings['ibm_notes_usr'].present?
        GobiertoPeople::Setting.create!(
          site: module_settings.site,
          key: 'IBM_NOTES_ENDPOINT_USR',
          value: module_settings.settings['ibm_notes_usr']
        )
        module_settings.settings.delete('ibm_notes_usr')
      end

      if module_settings.settings['ibm_notes_pwd'].present?
        GobiertoPeople::Setting.create!(
          site: module_settings.site,
          key: 'IBM_NOTES_ENDPOINT_PWD',
          value: module_settings.settings['ibm_notes_pwd']
        )
        module_settings.settings.delete('ibm_notes_pwd')
      end

      module_settings.save!
    end
  end
end
