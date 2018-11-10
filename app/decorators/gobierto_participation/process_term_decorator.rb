# frozen_string_literal: true

module GobiertoParticipation
  class ProcessTermDecorator < BaseDecorator
    def initialize(term)
      @object = term
    end

    def active_news
      GobiertoCms::Page.news_in_collections_and_container(site, object).sorted.active
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
      collection_items_table = ::GobiertoCommon::CollectionItem.table_name
      item_type = ::GobiertoCalendars::Event
      site.events.distinct.joins("INNER JOIN #{collection_items_table} ON \
                        #{collection_items_table}.item_id = #{item_type.table_name}.id AND \
                        #{collection_items_table}.item_type = '#{item_type}' AND \
                            container_type = '#{object.class.name}' AND \
                            container_id = #{object.id}\
                        ")
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
