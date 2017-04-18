module GobiertoCommon
  module LocalizedContent
    extend ActiveSupport::Concern

    included do
      translated_attribute_names.each do |attr_name|
        define_method "#{attr_name}_with_fallback" do
          self.send("#{attr_name}_#{I18n.locale}").presence ||
            self.send("#{attr_name}_translations").values.detect{|v| v.present? }
        end
      end
    end
  end
end
