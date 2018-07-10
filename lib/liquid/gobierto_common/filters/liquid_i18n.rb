# frozen_string_literal: true

# The <tt>LiquidI18nRails</tt> module allows us to use the +translate+
# method of Rails' I18n library within liquid templates. To use it,
# simply pass the name of the text entry to the +t+ filter:
#
#   {{ 'fundraiser.thank_you' | t }}
#
# The above tag is equivalent to calling:
#
#   I18n.t('fundraiser.thank_you')
#
# The parsing logic parses interpolation arguments using a regex, which
# is how liquid parse all its tags. It expects values of the form:
#
#   {{ 'fundraiser.donate, amount: $15, foo: bar' | t }}
#
# The +val+ method serves to facilitate variable interpolation in liquid.
# If the string "$15" is stored in a variable called my_amount, the above
# can be re-written as
#
#   {{ 'fundraiser.donate' | val: 'amount', my_amount | val: 'foo','bar' | t }}
#
# Because we don't have a proof that there's no degenerate case that makes
# the iterative regex loop forever, it limits to 10 interpolations per translation.
#
# The error logic here serves to ensure aggressive reporting of missing
# translations when in development and test mode. In those environments,
# if a template is rendered and a translation is missing, an exception
# will be raised. In production, it will show a fallback message.
#
# Because +Liquid+ catches +StandardError+, we've created another error
# class subclassed directly on Exception that will not be caught.

class I18n::TranslationMissing < Exception; end
class I18n::TooMuchInterpolation < StandardError; end

module LiquidI18n
  MAX_INTERPOLATIONS = 10

  def t(query)
    translation_key, interpolation_vals = parse_interpolation(query)
    begin
      I18n.t(translation_key, **interpolation_vals.merge(raise: !Rails.env.production?))
    rescue I18n::MissingTranslationData => e
      raise I18n::TranslationMissing.new(e.message)
    end
  end

  def val(base, key, value)
    "#{base}, #{key}: #{value}"
  end

  private

  def parse_interpolation(query)
    params, depth = {}, 0
    _, translation_key, string_params = /([^,]+)(.*)/.match(query).to_a
    while string_params.present? && string_params.length > 0
      if depth >= MAX_INTERPOLATIONS
        raise I18n::TooMuchInterpolation.new("More than #{MAX_INTERPOLATIONS} interpolation values are not allowed.")
      end
      _, key, val, string_params = /, *([a-zA-z_]+): *([^,]+)(.*)/.match(string_params).to_a
      params[key.to_sym] = val if key.present? && key.length > 0
      depth += 1
    end
    [translation_key, params]
  end
end

Liquid::Template.register_filter LiquidI18n
