# frozen_string_literal: true

module GobiertoCommon::CustomFieldFunctions
  class Table < Base

    def initialize(record, options = {})
      @version = options.delete(:version)

      super
    end

  end
end
