# frozen_string_literal: true

module GobiertoBudgets::DescribableTest
  class GobiertoBudgets::Klass
    include GobiertoBudgetsData::Describable
  end

  def test_all_descriptions
    descriptions = GobiertoBudgets::Klass.all_descriptions

    I18n.available_locales.each do |locale|
      assert descriptions[locale].present?
      assert_kind_of Hash, descriptions[locale]
    end
  end
end
