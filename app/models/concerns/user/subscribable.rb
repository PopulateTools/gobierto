module User::Subscribable
  extend ActiveSupport::Concern

  included do
    def self.subscribable_label
      model_name.human.pluralize
    end
  end

  def subscribable_label
    try(:title) || try(:name)
  end
end
