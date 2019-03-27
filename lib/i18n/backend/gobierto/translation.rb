# frozen_string_literal: true

module I18n
  module Backend
    # ActiveRecord model used to store actual translations to the database.
    #
    # This model expects a table like the following to be already set up in
    # your the database:
    #
    #   create_table :translations do |t|
    #     t.string :locale
    #     t.string :key
    #     t.text   :value
    #     t.text   :interpolations
    #     t.boolean :is_proc, :default => false
    #   end
    #
    # This model supports to named scopes :locale and :lookup. The :locale
    # scope simply adds a condition for a given locale:
    #
    #   I18n::Backend::ActiveRecord::Translation.locale(:en).all
    #   # => all translation records that belong to the :en locale
    #
    # The :lookup scope adds a condition for looking up all translations
    # that either start with the given keys (joined by an optionally given
    # separator or I18n.default_separator) or that exactly have this key.
    #
    #   # with translations present for :"foo.bar" and :"foo.baz"
    #   I18n::Backend::ActiveRecord::Translation.lookup(:foo)
    #   # => an array with both translation records :"foo.bar" and :"foo.baz"
    #
    #   I18n::Backend::ActiveRecord::Translation.lookup([:foo, :bar])
    #   I18n::Backend::ActiveRecord::Translation.lookup(:"foo.bar")
    #   # => an array with the translation record :"foo.bar"
    #
    # When the StoreProcs module was mixed into this model then Procs will
    # be stored to the database as Ruby code and evaluated when :value is
    # called.
    #
    #   Translation = I18n::Backend::ActiveRecord::Translation
    #   Translation.create \
    #     :locale => 'en'
    #     :key    => 'foo'
    #     :value  => lambda { |key, options| 'FOO' }
    #   Translation.find_by_locale_and_key('en', 'foo').value
    #   # => 'FOO'
    class Gobierto
      class Translation < ::ActiveRecord::Base
        TRUTHY_CHAR = "\001"
        FALSY_CHAR = "\002"
        GLOBAL_SCOPE = 0

        self.table_name = "translations"

        serialize :value
        serialize :interpolations, Array

        class << self
          def locale(locale)
            where(locale: locale.to_s)
          end

          def with_site(site)
            where(site_id: site.id)
          end

          def global
            where(site_id: nil)
          end

          def lookup(keys, *separator)
            column_name = connection.quote_column_name("key")
            keys = Array(keys).map! { |key| key.to_s }

            unless separator.empty?
              warn "[DEPRECATION] Giving a separator to Translation.lookup is deprecated. " <<
                "You can change the internal separator by overwriting FLATTEN_SEPARATOR."
            end

            namespace = "#{keys.last}#{I18n::Backend::Flatten::FLATTEN_SEPARATOR}%"
            where("#{column_name} IN (?) OR #{column_name} LIKE ?", keys, namespace)
          end

          def find_entry(options)
            locale  = options.fetch(:locale).to_sym
            site    = options.fetch(:site, nil)
            key     = options.fetch(:key, nil)
            site_id = site.try(:id) || GLOBAL_SCOPE

            if cached_entries[locale].nil? || cached_entries[locale][site_id].nil?
              reset_cached_entries!
            end

            if cached_entries[locale][site_id].has_key?(key)
              cached_entries[locale][site_id]
            elsif cached_entries[locale][GLOBAL_SCOPE].has_key?(key)
              cached_entries[locale][GLOBAL_SCOPE]
            else
              {}
            end
          end

          def available_locales
            Translation.select("DISTINCT locale").to_a.map { |t| t.locale.to_sym }
          end

          def reset_cached_entries!
            @cached_entries = nil
          end

          def cached_entries
            @cached_entries ||= begin
              cached_entries = {}
              I18n.available_locales.each do |locale|
                locale = locale.to_sym
                cached_entries[locale] ||= {}
                Site.all.each do |site|
                  cached_entries[locale][site.id] = Hash[self.locale(locale).with_site(site).pluck(:key, :value)]
                end
                cached_entries[locale][0] = Hash[self.locale(locale).global.pluck(:key, :value)]
              end
              cached_entries
            end
          end
        end

        def interpolates?(key)
          interpolations.include?(key) if interpolations
        end

        def value
          value = read_attribute(:value)
          if is_proc
            Kernel.eval(value)
          elsif value == FALSY_CHAR
            false
          elsif value == TRUTHY_CHAR
            true
          else
            value
          end
        end

        def value=(value)
          if value === false
            value = FALSY_CHAR
          elsif value === true
            value = TRUTHY_CHAR
          end

          write_attribute(:value, value)
        end
      end
    end
  end
end
