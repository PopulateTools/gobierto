# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    module CategoriesHelper
      SEM_COLORS = { blank: nil,
                     all: nil,
                     unsent: "color_sem_red",
                     sent: "color_sem_red",
                     in_review: "color_sem_yellow",
                     approved: "color_sem_green",
                     rejected: "color_sem_red" }.with_indifferent_access.freeze

      def moderation_stage_sem_color_class(stage)
        SEM_COLORS[stage]
      end
    end
  end
end
