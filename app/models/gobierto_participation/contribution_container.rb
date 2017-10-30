# frozen_string_literal: true

require_dependency "gobierto_participation"

module GobiertoParticipation
  class ContributionContainer < ApplicationRecord
    include User::Subscribable
    include GobiertoCommon::Sluggable

    translates :title, :description

    belongs_to :site
    belongs_to :process
    belongs_to :admin, class_name: "GobiertoAdmin::Admin"
    has_many :contributions

    enum visibility_level: { draft: 0, active: 1 }
    enum visibility_user_level: { registered: 0, verified: 1 }
    enum contribution_type: { idea: 0, question: 1, proposal: 2 }

    validates :site, :process, :title, :description, :admin, :visibility_user_level, presence: true

    def parameterize
      { slug: slug }
    end

    def attributes_for_slug
      [title]
    end

    def comments_count
      contributions.sum(:comments_count)
    end

    def participants_count
      contributions.sum(&:number_participants)
    end

    def days_left
      (ends - Date.current ).to_i
    end
  end
end
