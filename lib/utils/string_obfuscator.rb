# frozen_string_literal: true

require "bigdecimal"

# Credit to https://github.com/wealthsimple/string-obfuscator

class StringObfuscator

  def self.obfuscate(value, percent: nil, length: nil, from: :left, max_unobfuscated_length: nil, min_obfuscated_length: nil)
    raise ArgumentError, "must specify percent or length to obfuscate by" if percent.nil? && length.nil?
    raise ArgumentError, "percent must be between 0 - 100" if !percent.nil? && (percent > 100 || percent.negative?)
    raise ArgumentError, "length must be > 0" if !length.nil? && length.negative?
    return value unless value.is_a?(String)

    if !percent.nil?
      percent = BigDecimal(percent.to_s)
      obfuscated_length = (value.length * (percent / 100)).ceil
    else
      obfuscated_length = length
    end
    obfuscated_length = [obfuscated_length, min_obfuscated_length].max if min_obfuscated_length
    obfuscated_length = [obfuscated_length, value.length].min
    visible_length = value.length - obfuscated_length

    # If `max_unobfuscated_length` is set, ensure that we don't show more than that.
    if !max_unobfuscated_length.nil? && visible_length > max_unobfuscated_length
      visible_length = max_unobfuscated_length
      obfuscated_length = value.length - visible_length
    end

    obfuscation_value = "*" * obfuscated_length
    if visible_length.zero?
      obfuscation_value
    elsif from.to_sym == :left
      obfuscation_value + value[-visible_length..-1]
    else
      value[0..(visible_length - 1)] + obfuscation_value
    end
  end

end
