module GobiertoCommon
  class ContentBlock < ApplicationRecord
    belongs_to :site

    has_many :fields, dependent: :destroy, class_name: "ContentBlockField"
    has_many :records, dependent: :destroy, class_name: "ContentBlockRecord"

    serialize :title, Hash
  end
end
