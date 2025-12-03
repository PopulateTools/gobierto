# frozen_string_literal: true

class GobiertoAdmin::Moderation < ApplicationRecord
  belongs_to :site, optional: true
  belongs_to :admin, optional: true
  belongs_to :moderable, polymorphic: true

  enum stage: { unsent: 0,
                sent: 1,
                in_review: 2,
                approved: 3,
                rejected: 4 }

  STAGES_FLOW = { unsent: { sent: [:edit, :moderate] },
                  sent: { in_review: [:moderate], unsent: [:moderate] },
                  in_review: { sent: [:moderate],
                               approved: [:moderate],
                               rejected: [:moderate] },
                  approved: { in_review: [:edit, :moderate],
                              rejected: [:moderate] },
                  rejected: { in_review: [:moderate],
                              approved: [:moderate] } }.with_indifferent_access.freeze

  LOCKED_EDITION = { unsent: [:visibility_level],
                     sent: [:visibility_level],
                     in_review: [:visibility_level],
                     approved: [],
                     rejected: [:visibility_level] }.with_indifferent_access.freeze

  def available_stages
    STAGES_FLOW[stage].keys
  end

  def available_stages_for_action(action)
    STAGES_FLOW[stage].select do |_, actions|
      actions.include? action
    end
  end

  def actions_for_stage(next_stage)
    return [] unless STAGES_FLOW[stage].has_key? next_stage

    STAGES_FLOW[stage][next_stage]
  end

  def locked_edition?(attribute)
    LOCKED_EDITION[stage].include?(attribute.to_sym)
  end

  def reachable_stages_for_action(action, initial_stage = nil, accumulated = [])
    initial_stage ||= stage

    available_stages = STAGES_FLOW[initial_stage].select do |stage, actions|
      accumulated.exclude?(stage) && actions.include?(action)
    end

    return accumulated if available_stages.blank?

    accumulated += available_stages.keys
    available_stages.keys.map { |stage| reachable_stages_for_action(action, stage, accumulated) }.flatten.uniq
  end
end
