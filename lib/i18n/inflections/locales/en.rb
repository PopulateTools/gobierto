# frozen_string_literal: true

module I18n
  module Inflections
    class Locales::En < Base
      def initialize(text, opts = {})
        super
        @gender = :n
      end

      def to_your
        your
      end
    end
  end
end
