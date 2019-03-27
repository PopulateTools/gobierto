# frozen_string_literal: true

module GobiertoCommon
  class CustomUserFieldRecord < ApplicationRecord
    belongs_to :user
    belongs_to :custom_user_field

    validates :custom_user_field, :user, presence: true

    def value
      if custom_user_field && payload.present?
        if custom_user_field.string? || custom_user_field.paragraph?
          raw_value
        elsif custom_user_field.single_option?
          if raw_value.present? && custom_user_field.options[raw_value].present?
            custom_user_field.options[raw_value][I18n.locale.to_s]
          end
        elsif custom_user_field.multiple_options?
          Array(raw_value).map do |v|
            custom_user_field.options[v][I18n.locale.to_s]
          end
        end
      end
    end

    def raw_value
      @raw_value ||= if custom_user_field && payload.present?
        payload[custom_user_field.name]
      end
    end

    def value=(v)
      if custom_user_field
        self.payload = { custom_user_field.name => v }
      end
    end
  end
end
