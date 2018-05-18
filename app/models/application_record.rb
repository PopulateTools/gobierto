class ApplicationRecord < ActiveRecord::Base
  include GobiertoCommon::AttributeLengthValidatable

  self.abstract_class = true
end
