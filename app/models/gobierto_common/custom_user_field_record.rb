module GobiertoCommon
  class CustomUserFieldRecord < ApplicationRecord
    belongs_to :user
    belongs_to :custom_user_field

    def value
      if custom_user_field && payload.present?
        if custom_user_field.string? || custom_user_field.paragraph?
          payload[custom_user_field.name]
        elsif custom_user_field.single_option?
          if payload[custom_user_field.name].present? && custom_user_field.options[payload[custom_user_field.name]].present?
            custom_user_field.options[payload[custom_user_field.name]][I18n.locale.to_s]
          end
        elsif custom_user_field.multiple_options?
          if payload[custom_user_field.name]
            payload[custom_user_field.name].map do |v|
              custom_user_field.options[v][I18n.locale.to_s]
            end
          else
            []
          end
        end
      end
    end

    def value=(v)
      if custom_user_field
        self.payload = {custom_user_field.name => v}
      end
    end
  end
end
