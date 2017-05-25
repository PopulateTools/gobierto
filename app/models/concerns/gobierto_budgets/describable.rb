# frozen_string_literal: true

module GobiertoBudgets
  module Describable
    extend ActiveSupport::Concern

    module ClassMethods
      def all_descriptions
        @all_descriptions ||= begin
                                Hash[I18n.available_locales.map do |locale|
                                  path = "./db/data/budget_line_descriptions_#{locale}.yml"
                                  [locale, YAML.load_file(path)]
                                end]
                              end
      end
    end
  end
end
