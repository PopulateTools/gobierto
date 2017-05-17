require_dependency "gobierto_people"

module GobiertoPeople
  class PoliticalGroup < ApplicationRecord
    include GobiertoCommon::Sortable
    include GobiertoPeople::SearchableBySlug

    validates :site, presence: true

    belongs_to :admin, class_name: "GobiertoAdmin::Admin"
    belongs_to :site

    has_many :people
    has_many :events, through: :people

    before_save :set_slug

    default_scope { order(position: :asc) }

    private

    def set_slug
      if slug.nil?
        new_slug = GobiertoPeople::PoliticalGroup.generate_unique_slug(name)
        write_attribute(:slug, new_slug)
      end
    end

  end
end
