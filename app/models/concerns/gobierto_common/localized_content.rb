module GobiertoCommon
  module LocalizedContent
    extend ActiveSupport::Concern

    included do
      translated_attribute_names.each do |attr_name|
        define_method "#{attr_name}_with_fallback" do
          translated_attribute = self.send("#{attr_name}_#{I18n.locale}")
          return translated_attribute if translated_attribute.present?

          if attribute_translations = self.send("#{attr_name}_translations")
            attribute_translations.values.detect{|v| v.present? }
          end
        end
      end
    end
  end
end
