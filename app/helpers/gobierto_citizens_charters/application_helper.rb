# frozen_string_literal: true

module GobiertoCitizensCharters
  module ApplicationHelper
    def format_value(number, other_num = nil, absolute_value = false)
      return nil if number.blank?
      number = number.abs if absolute_value

      if [number, other_num].compact.any? { |n| n.abs > 1_000_000 }
        "#{helpers.number_with_precision(number.to_f / 1_000_000.to_f, precision: 1, strip_insignificant_zeros: true, delimiter: t("number.format.delimiter"))} M"
      else
        helpers.number_with_precision(number, precision: 1, strip_insignificant_zeros: true, delimiter: t("number.format.delimiter"))
      end
    end

    def format_percentage(number)
      helpers.number_to_percentage(number, precision: GobiertoCitizensCharters::Edition::SIGNIFICATIVE_DECIMALS, strip_insignificant_zeros: true)
    end
  end
end
