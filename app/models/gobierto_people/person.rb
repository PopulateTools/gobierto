require_dependency "gobierto_people"

module GobiertoPeople
  class Person < ApplicationRecord
    include ::GobiertoCommon::DynamicContent
    include User::Subscribable

    belongs_to :admin, class_name: "GobiertoAdmin::Admin"
    belongs_to :site
    belongs_to :political_group

    has_many :events, class_name: "PersonEvent", dependent: :destroy
    has_many :statements, class_name: "PersonStatement", dependent: :destroy
    has_many :posts, class_name: "PersonPost", dependent: :destroy

    scope :sorted, -> { order(created_at: :desc) }

    enum visibility_level: { draft: 0, active: 1 }
    enum category: { politician: 0, executive: 1 }
    enum party: { government: 0, opposition: 1 }
  end
end
