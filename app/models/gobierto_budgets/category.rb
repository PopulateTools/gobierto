# frozen_string_literal: true

module GobiertoBudgets
  class Category < ApplicationRecord
    include GobiertoBudgetsData::GobiertoBudgets::Describable

    belongs_to :site

    translates :custom_name, :custom_description

    validates :site, :area_name, :code, :kind, presence: true

    def area
      BudgetArea.klass_for(area_name)
    end

    def name
      custom_name_translations.try(:dig, I18n.locale.to_s) || default_name
    end

    def description
      custom_description_translations.try(:dig, I18n.locale.to_s) || default_description
    end

    def parent
      @parent ||= if parent_code.present?
                    self.class.find_by(site: site, area_name: area_name, kind: kind, code: parent_code)
                  end
    end

    def self.default_name(area, kind, code)
      area.all_items[kind][code]
    end

    def self.default_description(area, kind, code)
      area.all_descriptions[I18n.locale][area.area_name][kind][code] if area != CustomArea
    end

    private

    def default_name
      self.class.default_name(area, kind, code)
    end

    def default_description
      self.class.default_description(area, kind, code)
    end
  end
end
