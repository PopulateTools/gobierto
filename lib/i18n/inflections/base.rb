# frozen_string_literal: true

module I18n
  module Inflections
    class Base
      def self.create_with_locale(text, opts = {})
        locale = opts.delete(:locale) || I18n.locale
        Locales.const_get(locale.to_s.titleize).new(text, opts)
      end

      def initialize(text, opts = {})
        @text = text
        @start_key_word = nil
        @locale = opts[:locale]
        @gender = opts[:gender] || :n
      end

      [:our, :your].each do |particle|
        define_method(particle) { pr_t(particle) + @text }
      end

      def the
        pr_t(:the, apostrophize?) + @text
      end

      def of_the
        pr_t(:of_the, apostrophize?) + @text
      end

      def from_your
        from_t + your
      end

      def of_our
        of_t + our
      end

      def to_your
        to_t + your
      end

      private

      def from_t
        I18n.t("grammatical_particles.from") + " "
      end

      def of_t
        I18n.t("grammatical_particles.of") + " "
      end

      def to_t
        I18n.t("grammatical_particles.to") + " "
      end

      def pr_t(particle, apostrophized = false)
        if apostrophized
          I18n.t("grammatical_particles.#{particle}.apostrophized")
        else
          I18n.t("grammatical_particles.#{particle}.#{@gender}") + " "
        end
      end

      def apostrophize?
        false
      end
    end
  end
end
