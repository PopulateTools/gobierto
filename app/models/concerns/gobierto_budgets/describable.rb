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

        # TODO: do this properly
        custom_descriptions_path = './db/data/custom_budget_line_descriptions_ca.yml'
        custom_descriptions_file = YAML.load_file(custom_descriptions_path)
        @all_descriptions[:es]['custom'] = custom_descriptions_file
        @all_descriptions[:en]['custom'] = custom_descriptions_file
        @all_descriptions[:ca]['custom'] = custom_descriptions_file

        @all_descriptions
      end
    end
  end
end
