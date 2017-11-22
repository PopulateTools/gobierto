# frozen_string_literal: true

module GobiertoParticipation
  class ContributionDecorator < BaseDecorator
    VOTES = { 2 => { short_form: '++',
                     label: 'gobierto_participation.processes.contributions.contribution.enchants' },
              1 => { short_form: '+',
                     label: 'gobierto_participation.processes.contributions.contribution.like' },
              0 => { short_form: '0',
                     label: 'gobierto_participation.processes.contributions.contribution.indifferent' },
             -1 => { short_form: '-',
                     label: 'gobierto_participation.processes.contributions.contribution.not_like' } }

    def initialize(contribution)
      @object = contribution
    end

    def self.headings
      return VOTES
    end

    def votes_distribution
      @votes_distribution ||= votes.group(:vote_weight).count
    end
  end
end
