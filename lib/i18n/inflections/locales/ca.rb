# frozen_string_literal: true

module I18n
  module Inflections
    class Locales::Ca < Base
      def apostrophize?
        /\A[aeiou]/i.match(@text)
      end

      [:our, :your].each do |particle|
        define_method(particle) { pr_t(:the) + pr_t(particle) + @text }
      end

      def from_your
        pr_t(:of_the) + pr_t(:your) + @text
      end

      def of_our
        pr_t(:of_the) + pr_t(:our) + @text
      end

      def to_your
        pr_t(:to_your) + @text
      end
    end
  end
end
