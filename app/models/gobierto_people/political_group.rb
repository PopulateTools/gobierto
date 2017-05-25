# frozen_string_literal: true

require_dependency 'gobierto_people'

module GobiertoPeople
  class PoliticalGroup < ApplicationRecord
    include GobiertoCommon::Sortable
    include GobiertoPeople::Sluggable

    validates :site, presence: true

    belongs_to :admin, class_name: 'GobiertoAdmin::Admin'
    belongs_to :site

    has_many :people
    has_many :events, through: :people

    default_scope { order(position: :asc) }

    def attributes_for_slug
      [name]
    end
  end
end
