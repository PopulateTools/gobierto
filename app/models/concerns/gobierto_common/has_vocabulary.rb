# frozen_string_literal: true

module GobiertoCommon
  module HasVocabulary
    extend ActiveSupport::Concern

    included do
      class_variable_set :@@vocabularies, {}
    end

    class_methods do
      def has_vocabulary(name, opts = {})
        vocabularies = class_variable_get :@@vocabularies

        singularized_name = name.to_s.singularize.to_sym
        extra_opts = { foreign_key: opts[:column_name] }.compact
        vocabulary_module_setting = opts[:vocabulary_module_setting] || :"#{ name }_vocabulary_id"
        module_name = self.name.deconstantize
        vocabularies[singularized_name] = vocabulary_module_setting

        belongs_to singularized_name, extra_opts.merge(class_name: "GobiertoCommon::Term")

        define_singleton_method :vocabularies do
          vocabularies
        end

        define_singleton_method name do |site = nil|
          site ||= GobiertoCore::CurrentScope.current_site
          return GobiertoCommon::Term.none unless site.settings_for_module(module_name)
          site.vocabularies.find(site.settings_for_module(module_name).send(vocabulary_module_setting)).terms
        end

        scope :"of_#{singularized_name}", ->(term) { where(singularized_name => term) }

        class_variable_set :@@vocabularies, vocabularies
      end
    end
  end
end
