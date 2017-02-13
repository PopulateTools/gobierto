require_dependency "gobierto_people"

module GobiertoPeople
  class Person < ApplicationRecord
    include GobiertoCommon::DynamicContent
    include User::Subscribable
    include GobiertoCommon::Sortable
    include GobiertoCommon::Searchable

    algoliasearch_gobierto do
      attribute :site_id, :name, :charge, :bio, :updated_at
      searchableAttributes ['name', 'charge', 'bio']
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    belongs_to :admin, class_name: "GobiertoAdmin::Admin"
    belongs_to :site
    belongs_to :political_group

    has_many :events, class_name: "PersonEvent", dependent: :destroy
    has_many :statements, class_name: "PersonStatement", dependent: :destroy
    has_many :posts, class_name: "PersonPost", dependent: :destroy

    scope :sorted, -> { order(position: :asc, created_at: :desc) }
    scope :by_site, ->(site) { where(site_id: site.id) }

    enum visibility_level: { draft: 0, active: 1 }
    enum category: { politician: 0, executive: 1 }
    enum party: { government: 0, opposition: 1 }

    def visible?
      active?
    end

    private

    def resource_path
      gobierto_people_person_path(self.id)
    end
  end
end
