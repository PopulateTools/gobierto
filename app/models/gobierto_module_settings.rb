# frozen_string_literal: true

class GobiertoModuleSettings < ApplicationRecord
  self.table_name = 'gobierto_module_settings'
  belongs_to :site, touch: true

  def method_missing(method_name, *args)
    self.settings ||= {}
    method_name = method_name.to_s
    if /\A(\w+)=\z/ =~ method_name
      self.settings[$1] = args[0]
    else
      self.settings[method_name]
    end
  end

  def public_api_settings
    self.settings ||= {}

    self.settings.select do |_, value|
      value.is_a?(Hash) && value.delete("exposed_in_public_api")
    end
  end

end
