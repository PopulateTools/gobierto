# frozen_string_literal: true

module GobiertoPlans
  class PlanDataDecorator < BaseDecorator
    def initialize(plan)
      @object = plan
    end

    def csv
      categories = CollectionDecorator.new(object.categories.where(level: object.categories.maximum(:level)).order(:position), decorator: CategoryTermDecorator)

      collection = []
      categories.each do |category|
        if category.nodes.exists?
          collection += category.nodes
        else
          collection << category
        end
      end

      if collection.blank?
        collection << CategoryTermDecorator.new(
          categories_vocabulary.terms.new,
          vocabulary: categories_vocabulary,
          plan: self,
          site: site
        )
      end

      external_id_chars = collection.map { |node| node.external_id.to_s.chars.uniq }.flatten.uniq
      transform_function = external_id_chars.all? { |e| e.match?(/\d/) } ? :to_i : :to_s
      collection.sort! { |a, b| a.external_id.send(transform_function) <=> b.external_id.send(transform_function) }

      CSV.generate do |csv|
        csv << RowNodeDecorator.new(collection.first).headers
        collection.each do |item|
          csv << RowNodeDecorator.new(item).object
        end
      end.force_encoding('utf-8')
    end
  end
end
