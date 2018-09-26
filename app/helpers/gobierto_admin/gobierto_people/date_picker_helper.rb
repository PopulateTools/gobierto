# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPeople
    module DatePickerHelper

      SECONDS_TO_MILISECONDS_FACTOR = 1000

      def microseconds_since_epoch(form_builder, attribute)
        attr_value = form_builder.object.send(attribute.to_sym)

        if attr_value.blank?
          attr_value = Time.zone.now
        elsif attr_value.is_a?(String)
          attr_value = Time.zone.parse(attr_value)
        end

        return nil unless attr_value.respond_to?(:strftime)

        attr_value.strftime("%s").to_i * SECONDS_TO_MILISECONDS_FACTOR
      end

    end
  end
end
