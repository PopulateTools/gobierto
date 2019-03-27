# frozen_string_literal: true

module GobiertoPeople
  class PersonTermDecorator < BaseDecorator
    def initialize(term)
      @object = term
    end

    def people
      return GobiertoPeople::Person.none unless association_with_people

      GobiertoPeople::Person.where(association_with_people => object)
    end

    def events
      collections_table = GobiertoCommon::Collection.table_name
      site.events.distinct.includes(:collection).where(collections_table => { container: people })
    end

    def site
      @site ||= object.vocabulary.site
    end

    protected

    def association_with_people
      @association_with_people ||= begin
                                     return unless people_settings.present?

                                     GobiertoPeople::Person.vocabularies.find do |_, setting|
                                       people_settings.send(setting).to_i == object.vocabulary_id.to_i
                                     end&.first
                                   end
    end

    def people_settings
      @people_settings ||= site.gobierto_people_settings
    end
  end
end
