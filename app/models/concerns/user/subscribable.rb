# frozen_string_literal: true

module User::Subscribable
  extend ActiveSupport::Concern

  included do
    def self.subscribable_label
      model_name.human.pluralize(I18n.locale)
    end
  end

  def subscribable_label
    try(:title) || try(:name)
  end

end
