# frozen_string_literal: true

module GobiertoParticipation
  class ProcessTermDecorator < BaseDecorator
    def initialize(term)
      @object = term
    end

    def active_news
      news.sorted.active
    end

    def site
      @site ||= object.vocabulary.site
    end

    def number_contributions
      contributions.size
    end

    def number_contributing_neighbours
      contributions.pluck(:user_id).uniq.size
    end

    def contributions
      return GobiertoParticipation::Contribution.none unless association_with_processes

      terms_key = GobiertoParticipation::Process.reflections[association_with_processes.to_s].foreign_key
      processes_table = GobiertoParticipation::Process.table_name
      containers_table = GobiertoParticipation::ContributionContainer.table_name

      GobiertoParticipation::Contribution.joins(contribution_container: :process)
                                         .where("#{ containers_table }.visibility_level = ?", 1)
                                         .where("#{ processes_table }.#{terms_key} = ?", id)
    end

    def events
      ProcessCollectionDecorator.new(::GobiertoCalendars::Event).with_term(object)
    end

    def attachments
      ProcessCollectionDecorator.new(::GobiertoAttachments::Attachment).with_term(object)
    end

    def news
      ProcessCollectionDecorator.new(::GobiertoCms::Page, item_type: "GobiertoCms::News").with_term(object)
    end

    def processes
      return GobiertoParticipation::Process.none unless association_with_processes

      GobiertoParticipation::Process.where(association_with_processes => object)
    end

    protected

    def association_with_processes
      @association_with_processes ||= begin
                                        return unless participation_settings.present?

                                        GobiertoParticipation::Process.vocabularies.find do |_, setting|
                                          participation_settings.send(setting).to_i == object.vocabulary_id.to_i
                                        end&.first
                                      end
    end

    def participation_settings
      @participation_settings ||= site.gobierto_participation_settings
    end
  end
end
